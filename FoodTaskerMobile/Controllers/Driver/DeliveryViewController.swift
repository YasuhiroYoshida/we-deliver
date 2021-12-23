//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import MapKit
import SwiftyJSON

class DeliveryViewController: MapKitEnabledViewController {
  // MARK: - Vars
  var orderId: Int?
  // MARK: - Vars - Inherited
//var locationMgr = CLLocationManager()
//var driverLocationCoordinate: CLLocationCoordinate2D!
//var sourceMKPlacemark: MKPlacemark?
//var destinationMKPlacemark: MKPlacemark?
//var driverDropPinAnnotation: MKPointAnnotation!

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var mapMapView: MKMapView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var recipientNameLabel: UILabel!
  @IBOutlet weak var recipientAddressLabel: UILabel!
  @IBOutlet weak var recipientInfoView: UIView!
  @IBOutlet weak var completeOrderButton: UIButton!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    loadDelivery()

    if CLLocationManager.locationServicesEnabled() {
      locationMgr.delegate = self
      locationMgr.desiredAccuracy = kCLLocationAccuracyBest
      locationMgr.requestAlwaysAuthorization()
      locationMgr.requestWhenInUseAuthorization()
      locationMgr.startUpdatingLocation()
      mapMapView.showsUserLocation = true
    }
    if UpdateLocaionTimer == nil {
      print("あああ")
      UpdateLocaionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
        self.updateDriverLocation()
      }
    }
  }

  private func loadDelivery() {
    APIClient.shared.delivery { json in

      if let delivery = json?["delivery"], delivery["status"].string == OrderStatus.onTheWay.rawValue {
        self.orderId = delivery["id"].int!
        let sourceAddress = delivery["restaurant"]["address"].string!
        let destinationAddress = delivery["address"].string!

        let recipientAvatarLink = delivery["customer"]["avatar"].string!
        if let data = try? Data(contentsOf: URL(string: recipientAvatarLink)!) {
          self.avatarImageView.image = UIImage(data: data)
        }
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor
        self.avatarImageView.layer.borderWidth = 1
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.backgroundColor = .clear
        let recipientName = delivery["customer"]["name"].string!
        self.recipientNameLabel.text = recipientName
        self.recipientAddressLabel.text = destinationAddress

        self.convertAddressToCLPlacemark(sourceAddress) { sourceCLPlacemark in

          if let sourceLocation = sourceCLPlacemark.location {

            self.setDropPinAnnotation(on: &self.mapMapView, at: sourceLocation, titled: "Restaurant")
            self.sourceMKPlacemark = MKPlacemark(placemark: sourceCLPlacemark)

            self.convertAddressToCLPlacemark(destinationAddress) { destinationCLPlacemark in

              if let destinationLocation = destinationCLPlacemark.location {

                self.setDropPinAnnotation(on: &self.mapMapView, at: destinationLocation, titled: "Customer")
                self.destinationMKPlacemark = MKPlacemark(placemark: destinationCLPlacemark)

                self.drawRoutes(on: &self.mapMapView)
              }
            }
          }
        }
      } else {
        self.showMessageOnly()
      }
    }
  }

  private func updateDriverLocation() {
    guard driverLocationCoordinate != nil else { return }

    APIClient.shared.updateLocation(driverLocationCoordinate) {_ in }
  }

  private func showMessageOnly() {
    mapMapView.isHidden = true
    recipientInfoView.isHidden = true
    completeOrderButton.isHidden = true

    let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: 40.0))
    label.center = view.center
    label.textAlignment = .center
    label.text = "You have no outstanding order"
    view.addSubview(label)
  }

  @IBAction func completeOrderButtonPressed(_ sender: Any) {
    UpdateLocaionTimer.invalidate()
    UpdateLocaionTimer = nil
  }

  // MARK: - Navigation
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "DeliveryView2OrderMenuTableView" {
//      print("ああああああ")
//      updateLocaionTimer.invalidate()
//      updateLocaionTimer = nil
//      updateStatusTimer.invalidate()
//      updateStatusTimer = nil
//    }
//  }
}

// MARK: MKMapViewDelegate
//extension DeliveryViewController: MKMapViewDelegate {
//
//  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//    let renderer = MKPolylineRenderer(overlay: overlay)
//    renderer.strokeColor = .black
//    renderer.lineWidth = 5
//    return renderer
//  }
//
//  private func convertAddressToCLPlacemark(_ address: String, completion: @escaping (CLPlacemark) -> Void) {
//    CLGeocoder().geocodeAddressString(address) { cLPlacemarks, error in
//      guard error == nil else { return }
//
//      if let cLPlacemark = cLPlacemarks?.first {
//        completion(cLPlacemark)
//      }
//    }
//  }
//
//  private func setDropPinAnnotation(at location: CLLocation, titled title: String = "") {
//    let dropPinAnnotation = MKPointAnnotation()
//    dropPinAnnotation.coordinate = location.coordinate
//    dropPinAnnotation.title = title
//    mapMapView.addAnnotation(dropPinAnnotation)
//  }
//
//  private func drawRoutes() {
//    let request = requestForRoutes()
//    MKDirections(request: request).calculate { response, error in
//      guard error == nil else { return }
//      self.renderRoutesOnMap(response!.routes)
//    }
//  }
//
//  private func requestForRoutes() -> MKDirections.Request {
//    let request = MKDirections.Request()
//    request.source = MKMapItem(placemark: sourceMKPlacemark!)
//    request.destination = MKMapItem(placemark: destinationMKPlacemark!)
//    request.requestsAlternateRoutes = false
//    return request
//  }
//
//  private func renderRoutesOnMap(_ routes: [MKRoute]) {
//    for route in routes {
//      mapMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
//    }
//    mapMapView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
//    mapMapView.showAnnotations(mapMapView.annotations, animated: true)
//  }
//}

// MARK: - CLLocationManagerDelegate
extension DeliveryViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {

      driverLocationCoordinate = location.coordinate

      if driverDropPinAnnotation != nil {
        driverDropPinAnnotation.coordinate = driverLocationCoordinate
      } else {
        driverDropPinAnnotation = MKPointAnnotation()
        driverDropPinAnnotation.coordinate = driverLocationCoordinate
        mapMapView.addAnnotation(driverDropPinAnnotation)
      }

      mapMapView.layoutMargins = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: CGFloat(10), right: CGFloat(10))
      mapMapView.showAnnotations(mapMapView.annotations, animated: true)
    }
  }
}
