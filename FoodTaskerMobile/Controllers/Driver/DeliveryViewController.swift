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

    if CLLocationManager.locationServicesEnabled() {
      locationMgr.delegate = self
      locationMgr.desiredAccuracy = kCLLocationAccuracyBest
      locationMgr.requestAlwaysAuthorization()
      locationMgr.requestWhenInUseAuthorization()
      locationMgr.startUpdatingLocation()
      mapMapView.showsUserLocation = true
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadDelivery()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UpdateLocaionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
      self.updateDriverLocation()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    Utils.stopTimers()
  }

  private func loadDelivery() {
    APIClient.shared.delivery { json in
      guard let delivery = json?["delivery"], delivery["status"].string == OrderStatus.onTheWay.rawValue else {
        self.showMessageOnly()
        return
      }

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
  }
}

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
        driverDropPinAnnotation.title = "Driver"
        mapMapView.addAnnotation(driverDropPinAnnotation)
      }

      mapMapView.layoutMargins = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: CGFloat(10), right: CGFloat(10))
      mapMapView.showAnnotations(mapMapView.annotations, animated: true)
    }
  }
}
