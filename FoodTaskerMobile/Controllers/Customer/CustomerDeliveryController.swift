//
//  CustomerDeliveryController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-01.
//

import UIKit
import MapKit

class CustomerDeliveryController: UIViewController {
  // MARK: - Vars
  var status: String?
  var sourcePlacemark: MKPlacemark? // source == origin == restaurant
  var destinationPlacemark: MKPlacemark? // destination == customer

  // MARK: - IBOutlet
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var acceptedImageView: UIImageView!
  @IBOutlet weak var readyImageView: UIImageView!
  @IBOutlet weak var onTheWayImageView: UIImageView!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var mapMapView: MKMapView!
  @IBOutlet weak var driverInfoView: UIView!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if self.revealViewController() != nil {
      menuBarButtonItem.target = self.revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    updateLocations()

    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
      self.updateStatus()
    }
  }

  private func updateLocations() {

    APIClient.shared.latestOrder { json in
      let latestOrder = json!["latest_order"]
      let restaurantAddress = latestOrder["restaurant"]["address"].string!
      let deliveryAddress = latestOrder["address"].string!

      self.updatePlacemrk(restaurantAddress, title: "Restaurant") { restaurantMapKitPlacemark in
        self.sourcePlacemark = restaurantMapKitPlacemark

        self.updatePlacemrk(deliveryAddress, title: "Customer") { customerMapKitPlacemark in
          self.destinationPlacemark = customerMapKitPlacemark
          self.updateDirection()
        }
      }
    }
  }

  private func updateStatus() {

    APIClient.shared.latestOrderStatus { json in

      if let status = json!["latest_order_status"]["status"].string {

        self.status = status

        switch status {
        case OrderStatus.ready.rawValue:
          self.acceptedImageView.alpha = CGFloat(1.0)
          self.readyImageView.alpha = CGFloat(1.0)
          self.onTheWayImageView.alpha = CGFloat(0.2)
          self.driverInfoView.isHidden = false
        case OrderStatus.onTheWay.rawValue:
          self.acceptedImageView.alpha = CGFloat(1.0)
          self.readyImageView.alpha = CGFloat(1.0)
          self.onTheWayImageView.alpha = CGFloat(1.0)
          self.driverInfoView.isHidden = false
        default:
          self.acceptedImageView.alpha = CGFloat(0.2)
          self.readyImageView.alpha = CGFloat(0.2)
          self.onTheWayImageView.alpha = CGFloat(0.2)
          self.driverInfoView.isHidden = true
          break
        }
      }
    }
  }
}

extension CustomerDeliveryController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .black
    renderer.lineWidth = 5
    return renderer
  }

  func updatePlacemrk(_ address: String, title: String, completion: @escaping (MKPlacemark) -> Void) {

    CLGeocoder().geocodeAddressString(address) { placemarks, error in
      guard error == nil else {
        print("Error for \(title): ", error!.localizedDescription)
        return
      }

      if let placemark = placemarks!.first {
        if let location = placemark.location {

          let dropPinAnnotation = MKPointAnnotation()
          dropPinAnnotation.coordinate = location.coordinate
          dropPinAnnotation.title = title
          self.mapMapView.addAnnotation(dropPinAnnotation)

          let mapKitPlacemark = MKPlacemark(placemark: placemark)
          completion(mapKitPlacemark)
        }
      }
    }
  }

  func updateDirection() {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: sourcePlacemark!)
    request.destination = MKMapItem(placemark: destinationPlacemark!)
    request.requestsAlternateRoutes = false

    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }

      self.showRoutes(response!)
    }
  }

  func showRoutes(_ response: MKDirections.Response) {
    for route in response.routes {
      mapMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
    }
    mapMapView.layoutMargins = UIEdgeInsets(top: CGFloat(10.0), left: CGFloat(10.0), bottom: CGFloat(10.0), right: CGFloat(10.0))
    mapMapView.showAnnotations(mapMapView.annotations, animated: true)

  }
}

