//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-01.
//

import UIKit
import MapKit
import SwiftyJSON

class DeliveryViewController: MapKitEnabledViewController {
  // MARK: - Vars
  var status: String!
  // MARK: - Vars - Inherited
  //var locationMgr = CLLocationManager()
  //var driverLocationCoordinate: CLLocationCoordinate2D!
  //var sourceMKPlacemark: MKPlacemark?
  //var destinationMKPlacemark: MKPlacemark?
  //var driverDropPinAnnotation: MKPointAnnotation!

  // MARK: - IBOutlet
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var acceptedImageView: UIImageView!
  @IBOutlet weak var readyImageView: UIImageView!
  @IBOutlet weak var onTheWayImageView: UIImageView!
  @IBOutlet weak var statusView: UIView!
  @IBOutlet weak var mapMapView: MKMapView!
  @IBOutlet weak var driverInfoView: UIView!
  @IBOutlet weak var driverAvatarImageView: UIImageView!
  @IBOutlet weak var driverNameLabel: UILabel!
  @IBOutlet weak var driverCarModelAndPlateNumberLabel: UILabel!

  // MARK: - Lifecycles
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UpdateStatusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
      self.updateStatus()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    Utils.stopTimers()
  }
  
  private func updateMap() {

    APIClient.shared.order { json in

      if let order = json?["order"], order["status"].string == OrderStatus.onTheWay.rawValue {

        self.loadDriverInfo(order["driver"])

        let sourceAddress = order["restaurant"]["address"].string!
        let destinationAddress = order["address"].string!

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

          UpdateLocaionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
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
            self.driverDropPinAnnotation.title = CharacterType.Driver.rawValue
            self.mapMapView.addAnnotation(self.driverDropPinAnnotation)
          }

          self.mapMapView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
          self.mapMapView.showAnnotations(self.mapMapView.annotations, animated: true)
        }
      }
    }
  }

  private func loadDriverInfo(_ driver: JSON) {
    if let image = try? UIImage(data: Data(contentsOf: URL(string: driver["avatar"].string!)!)) {
      self.driverAvatarImageView.image = image
      self.driverAvatarImageView.layer.cornerRadius = self.driverAvatarImageView.frame.width / 2
      self.driverAvatarImageView.layer.borderColor = UIColor.white.cgColor
      self.driverAvatarImageView.layer.borderWidth = 1
      self.driverAvatarImageView.clipsToBounds = true
    }
    self.driverNameLabel.text = driver["name"].string
    self.driverCarModelAndPlateNumberLabel.text = "\(driver["car_model"]) - \(driver["plate_number"])"
  }

  private func updateStatus() {

    APIClient.shared.orderStatus { json in

      if let orderStatus = json?["order_status"] {

        switch orderStatus["status"].string {
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
          if UpdateLocaionTimer == nil {
            self.updateMap()
          }
        case OrderStatus.delivered.rawValue:
          self.acceptedImageView.alpha = 1.0
          self.readyImageView.alpha = 1.0
          self.onTheWayImageView.alpha = 1.0
          self.driverInfoView.isHidden = false
          Utils.stopTimers()
          self.closeMapIf30MinutesSince(pickedAt: orderStatus["picked_at"].string!)
        default: // Already exhaustive with the above conditions
          break
        }
      }
    }
  }

  private func closeMapIf30MinutesSince(pickedAt: String) {
    guard !pickedAt.isEmpty else { return }

    let alertController = UIAlertController(title: "Your order has arrived!", message: "Enjoy your meal! 🥳", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(action)
    present(alertController, animated: true)

    let _pickedAt = ISO8601DateFormatter().date(from: pickedAt)
    if let closingTime = _pickedAt?.addingTimeInterval(TimeInterval(60.0 * 2)), Date() > closingTime {
      self.statusView.isHidden = true
      self.mapMapView.isHidden = true
      self.driverInfoView.isHidden = true

      let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 40.0))
      label.center = self.view.center
      label.textAlignment = .center
      label.text = "There is no outstanding order for you"
      self.view.addSubview(label)
    }
  }
}
