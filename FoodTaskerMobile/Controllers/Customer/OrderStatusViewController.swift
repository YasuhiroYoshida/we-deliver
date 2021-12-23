//
//  OrderStatusViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-01.
//

import UIKit
import MapKit

class OrderStatusViewController: UIViewController {
  // MARK: - Vars
  var status: String?
  var locationMgr = CLLocationManager()
  var driverLocationCoordinate: CLLocationCoordinate2D!
  var sourceMKPlacemark: MKPlacemark?
  var destinationMKPlacemark: MKPlacemark?
  var driverDropPinAnnotation: MKPointAnnotation!

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

    updateMap()

    // Enable a timer to update the order status
    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
      self.updateStatus()
    }
  }

  private func updateMap() {

    APIClient.shared.order { json in
      guard let order = json?["order"], let status = order["status"].string, status != OrderStatus.delivered.rawValue else {

        self.acceptedImageView.isHidden = true
        self.readyImageView.isHidden = true
        self.onTheWayImageView.isHidden = true
        self.statusView.isHidden = true
        self.mapMapView.isHidden = true
        self.driverInfoView.isHidden = true

        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 40.0))
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "There is no outstanding order for you"
        self.view.addSubview(label)

        return
      }

      if status == OrderStatus.onTheWay.rawValue {

        let sourceAddress = order["restaurant"]["address"].string!
        let destinationAddress = order["address"].string!

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

          // Enable a timer to update an on-the-way order
          Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.updateOrderLocaion()
          }
        }
      }
    }
  }

  private func updateOrderLocaion() {
    APIClient.shared.orderLocation { json in
      if let orderLocation = json?["order_location"].string, !orderLocation.isEmpty {
        let coordinate = orderLocation.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")
        if let latitude = CLLocationDegrees(coordinate[0]), let longitude = CLLocationDegrees(coordinate[1]) {
          self.driverLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

          if self.driverDropPinAnnotation != nil {
            self.driverDropPinAnnotation.coordinate = self.driverLocationCoordinate
          } else {
            self.driverDropPinAnnotation = MKPointAnnotation()
            self.driverDropPinAnnotation.coordinate = self.driverLocationCoordinate
            self.mapMapView.addAnnotation(self.driverDropPinAnnotation)
          }

          self.mapMapView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
          self.mapMapView.showAnnotations(self.mapMapView.annotations, animated: true)
        }
      }
    }
  }

  // Just status. Not concerning location.
  private func updateStatus() {

    APIClient.shared.orderStatus { json in

      if let status = json?["order_status"].string {

        self.status = status

        switch self.status {
        case OrderStatus.cooking.rawValue:
          self.acceptedImageView.alpha = 1.0
          self.readyImageView.alpha = 0.2
          self.onTheWayImageView.alpha = 0.2
          self.driverInfoView.isHidden = true
        case OrderStatus.ready.rawValue:
          self.acceptedImageView.alpha = 1.0
          self.readyImageView.alpha = 1.0
          self.onTheWayImageView.alpha = 0.2
          self.driverInfoView.isHidden = true
        case OrderStatus.onTheWay.rawValue:
          self.acceptedImageView.alpha = 1.0
          self.readyImageView.alpha = 1.0
          self.onTheWayImageView.alpha = 1.0
          self.driverInfoView.isHidden = false
        case OrderStatus.delivered.rawValue:
          self.acceptedImageView.alpha = 0.2
          self.readyImageView.alpha = 0.2
          self.onTheWayImageView.alpha = 0.2
          self.driverInfoView.isHidden = true
        default: // Already exhaustive with the above conditions
          break
        }
      }
    }
  }
}

// MARK: - MKMapViewDelegate
extension OrderStatusViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = .black
    renderer.lineWidth = 5
    return renderer
  }

  private func convertAddressToCLPlacemark(_ address: String, completion: @escaping (CLPlacemark) -> Void) {

    CLGeocoder().geocodeAddressString(address) { cLPlacemarks, error in
      guard error == nil else { return }

      if let clPlacemark = cLPlacemarks?.first {
        completion(clPlacemark)
      }
    }
  }

  private func setDropPinAnnotation(at location: CLLocation, titled title: String = "") {
    let dropPinAnnotation = MKPointAnnotation()
    dropPinAnnotation.coordinate = location.coordinate
    dropPinAnnotation.title = title
    mapMapView.addAnnotation(dropPinAnnotation)
  }

  private func drawRoutes() {
    let request = requestForRoutes()
    MKDirections(request: request).calculate { response, error in
      guard error == nil else { return }
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
    mapMapView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    mapMapView.showAnnotations(mapMapView.annotations, animated: true)
  }
}
