//
//  CustomerDeliveryController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-01.
//

import UIKit
import MapKit

class CustomerDeliveryViewController: UIViewController {
  // MARK: - Vars
  var status: String?
  var sourceMKPlacemark: MKPlacemark?
  var destinationMKPlacemark: MKPlacemark?
  var driverDropPinAnnotation: MKPointAnnotation!
  var driverLocationCoordinate: CLLocationCoordinate2D!
  var locationMgr = CLLocationManager()

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

    updateMap()

    // Enable a timer to update the order status
    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
      self.updateStatus()
    }
  }

  private func updateOrderLocaion() {
    APIClient.shared.orderLocation { json in
      if let orderLocation = json!["order_location"].string, !orderLocation.isEmpty {
        let coordinatePoints = orderLocation.split(separator: ",")
        if let latitude = CLLocationDegrees(coordinatePoints[0]), let longitude = CLLocationDegrees(coordinatePoints[1]) {
          self.driverLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

          if self.driverDropPinAnnotation != nil {
            self.driverDropPinAnnotation.coordinate = self.driverLocationCoordinate
          } else {
            self.driverDropPinAnnotation = MKPointAnnotation()
            self.driverDropPinAnnotation.coordinate = self.driverLocationCoordinate
            self.mapMapView.addAnnotation(self.driverDropPinAnnotation)
          }

          self.mapMapView.layoutMargins = UIEdgeInsets(top: CGFloat(10.0), left: CGFloat(10.0), bottom: CGFloat(10.0), right: CGFloat(10.0))
          self.mapMapView.showAnnotations(self.mapMapView.annotations, animated: true)
        }
      }
    }
  }

  private func updateMap() {

    APIClient.shared.latestOrderByCustomer { json in
      if let latestOrder = json?["latest_order"] {

        if latestOrder["status"] == "On the way" {

          let sourceAddress = latestOrder["restaurant"]["address"].string!
          let destinationAddress = latestOrder["address"].string!

          self.convertAddressToCLPlacemark(sourceAddress) { sourceCLPlacemark in

            if let sourceLocation = sourceCLPlacemark.location {

              self.setDropPinAnnotation(at: sourceLocation, titled: "Restaurant")
              self.sourceMKPlacemark = MKPlacemark(placemark: sourceCLPlacemark)

              self.convertAddressToCLPlacemark(destinationAddress) { destinationCLPlacemark in

                if let destinationLocation = destinationCLPlacemark.location {

                  self.setDropPinAnnotation(at: destinationLocation, titled: "Customer")
                  self.destinationMKPlacemark = MKPlacemark(placemark: destinationCLPlacemark)

                  self.drawRoutes()
                }
              }
            }
          }

          // Enable a timer once to update an on-the-way order location once such thing is discovered
          Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.updateOrderLocaion()
          }
        } else {
          let label = UILabel(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: self.view.frame.size.width, height: CGFloat(40.0)))
          label.center = self.view.center
          label.textAlignment = .center
          label.text = "There is no outstanding order for you"
          self.view.addSubview(label)
        }
      }
    }
  }

  private func updateStatus() {

    APIClient.shared.latestOrderStatus { json in

      if let status = json?["latest_order_status"]["status"].string {

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

// MARK: - MKMapViewDelegate
extension CustomerDeliveryViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .black
    renderer.lineWidth = 5
    return renderer
  }

  func convertAddressToCLPlacemark(_ address: String, completion: @escaping (CLPlacemark) -> Void) {

    CLGeocoder().geocodeAddressString(address) { cLPlacemarks, error in
      guard error == nil else {
        print("Address conversion failed: ", error!.localizedDescription)
        return
      }

      if let clPlacemark = cLPlacemarks?.first {
        completion(clPlacemark)
      }
    }
  }

  private func setDropPinAnnotation(at location: CLLocation, titled title: String?) {
    let dropPinAnnotation = MKPointAnnotation()
    dropPinAnnotation.coordinate = location.coordinate
    if let _title = title {
      dropPinAnnotation.title = _title
    }
    mapMapView.addAnnotation(dropPinAnnotation)
  }

  private func drawRoutes() {
    let request = requestForRoutes()
    MKDirections(request: request).calculate { response, error in
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      self.renderRoutesOnMap(response!.routes)
    }
  }

  private func requestForRoutes() -> MKDirections.Request {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: sourceMKPlacemark!)
    request.destination = MKMapItem(placemark: destinationMKPlacemark!)
    request.requestsAlternateRoutes = false
    return request
  }

  private func renderRoutesOnMap(_ routes: [MKRoute]) {
    for route in routes {
      mapMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
    }
    mapMapView.layoutMargins = UIEdgeInsets(top: CGFloat(10.0), left: CGFloat(10.0), bottom: CGFloat(10.0), right: CGFloat(10.0))
    mapMapView.showAnnotations(mapMapView.annotations, animated: true)
  }
}
