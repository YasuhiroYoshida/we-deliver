//
//  DriverDeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import MapKit
import SwiftyJSON

class DriverDeliveryViewController: UIViewController {
  // MARK: - Vars
  var orderId: Int?
  var sourceMKPlacemark: MKPlacemark?
  var destinationMKPlacemark: MKPlacemark?
  var driverDropPinAnnotation: MKPointAnnotation!
  var driverLocationCoordinate: CLLocationCoordinate2D!
  var locationMgr = CLLocationManager()

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var mapMapView: MKMapView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var customerNameLabel: UILabel!
  @IBOutlet weak var customerAddressLabel: UILabel!
  @IBOutlet weak var customerInfoView: UIView!
  @IBOutlet weak var completeOrderButton: UIButton!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    loadLatestOrderForDriver()

    if CLLocationManager.locationServicesEnabled() {
      locationMgr.delegate = self
      locationMgr.desiredAccuracy = kCLLocationAccuracyBest
      locationMgr.requestAlwaysAuthorization()
      locationMgr.requestWhenInUseAuthorization()
      locationMgr.startUpdatingLocation()
      mapMapView.showsUserLocation = true
    }

    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
      self.updateDriverLocation()
    }
  }

  private func updateDriverLocation() {
    guard driverLocationCoordinate != nil else { return }

    APIClient.shared.updateDriverLocation(driverLocationCoordinate) {_ in }
  }

  private func loadLatestOrderForDriver() {

    APIClient.shared.latestOrderForDriver { json in

      if let latest_order = json?["latest_order"], latest_order["status"].string == "On the way" {
        self.orderId = latest_order["id"].int!
        let sourceAddress = latest_order["restaurant"]["address"].string!
        let destinationAddress = latest_order["address"].string!

        let customerAvatarLink = latest_order["customer"]["avatar"].string!
        if let data = try? Data(contentsOf: URL(string: customerAvatarLink)!) {
          self.avatarImageView.image = UIImage(data: data)
        }
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor
        self.avatarImageView.layer.borderWidth = 1
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.backgroundColor = .clear
        let customerName = latest_order["customer"]["name"].string!
        self.customerNameLabel.text = customerName
        self.customerAddressLabel.text = destinationAddress

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
      } else {
        self.showMessageOnly()
      }
    }
  }

  private func showMessageOnly() {
    mapMapView.isHidden = true
    customerInfoView.isHidden = true
    completeOrderButton.isHidden = true

    let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
    label.center = view.center
    label.textAlignment = .center
    label.text = "You have no outstanding order"
    view.addSubview(label)
  }

  @IBAction func completeOrderButtonPressed(_ sender: Any) {}
}

// MARK: MKMapViewDelegate
extension DriverDeliveryViewController: MKMapViewDelegate {

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

      if let cLPlacemark = cLPlacemarks?.first {
        completion(cLPlacemark)
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

// MARK: - CLLocationManagerDelegate
extension DriverDeliveryViewController: CLLocationManagerDelegate {

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
