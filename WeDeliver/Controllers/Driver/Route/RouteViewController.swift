//
//  RouteViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import MapKit
import SwiftyJSON

class RouteViewController: MapKitEnabledViewController {
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
      if let data = try? Data(contentsOf: URL(string: recipientAvatarLink)!) {// ✅
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

          self.setDropPinAnnotation(on: &self.mapMapView, at: sourceLocation, titled: CharacterType.Restaurant.rawValue)
          self.sourceMKPlacemark = MKPlacemark(placemark: sourceCLPlacemark)

          self.convertAddressToCLPlacemark(destinationAddress) { destinationCLPlacemark in

            if let destinationLocation = destinationCLPlacemark.location {

              self.setDropPinAnnotation(on: &self.mapMapView, at: destinationLocation, titled: CharacterType.Recipient.rawValue)
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

    APIClient.shared.updateLocation(driverLocationCoordinate)
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
    let confirmationController = UIAlertController(title: "Completed the task?", message: "", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
      if let _orderId = self.orderId {
        APIClient.shared.updateOrder(id: _orderId, newStatus: OrderStatus.delivered) { json in
          Utils.stopTimers()

          let alertController = UIAlertController(title: "Task Completed!", message: "Congratulations! You will be taken to Orders", preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.performSegue(withIdentifier: "RoutesView2OrdersTableView", sender: self)
          }
          alertController.addAction(action)
          self.present(alertController, animated: true)
        }
      }
    })
    let noAction = UIAlertAction(title: "No", style: .cancel)
    confirmationController.addAction(yesAction)
    confirmationController.addAction(noAction)
    self.present(confirmationController, animated: true)
  }
}

// MARK: - CLLocationManagerDelegate
extension RouteViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if let location = locations.last {

      driverLocationCoordinate = location.coordinate

      if driverDropPinAnnotation != nil {
        driverDropPinAnnotation.coordinate = driverLocationCoordinate
      } else {
        driverDropPinAnnotation = MKPointAnnotation()
        driverDropPinAnnotation.coordinate = driverLocationCoordinate
        driverDropPinAnnotation.title = CharacterType.Driver.rawValue
        mapMapView.addAnnotation(driverDropPinAnnotation)
      }

      mapMapView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
      mapMapView.showAnnotations(mapMapView.annotations, animated: true)
    }
  }
}
