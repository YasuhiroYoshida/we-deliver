//
//  CartViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-30.
//

import UIKit
import MapKit

class CartViewController: UIViewController {
  // MARK: - Vars
  var locationMgr = CLLocationManager()

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var cartTableView: UITableView!
  @IBOutlet weak var totalView: UIView!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var addressTextField: UITextField!
  @IBOutlet weak var mapMapView: MKMapView!
  @IBOutlet weak var checkoutButton: UIButton!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if let controller = revealViewController() {
      menuBarButtonItem.target = controller
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(controller.panGestureRecognizer())
    }

    if Cart.currentCart.cartItems.count == 0 {
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width , height: 40))
      label.center = view.center
      label.textAlignment = .center
      label.text = "Your cart is empty. Please select a meal."
      view.addSubview(label)
    } else {
      cartTableView.isHidden = false
      totalView.isHidden = false
      addressView.isHidden = false
      mapMapView.isHidden = false
      checkoutButton.isHidden = false
      cartTableView.reloadData()

      totalLabel.text = Cart.currentCart.total.currencyEUR
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

  // MARK: - IBActions
  @IBAction func addressTextField(_ sender: Any) {}
  @IBAction func goToCheckoutPressed(_ sender: Any) {
    guard let address = addressTextField.text, !address.isEmpty else {
      let action = UIAlertAction(title: "OK", style: .default) { _ in
        self.addressTextField.becomeFirstResponder()
      }
      let alertController = UIAlertController(title: "Delivery address required", message: "We need your delivery address", preferredStyle: .alert)
      alertController.addAction(action)
      present(alertController, animated: true)
      return
    }

    Cart.currentCart.deliveryAddress = address
    performSegue(withIdentifier: "CartView2PaymentView", sender: self)
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CartViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Cart.currentCart.cartItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cartItem = Cart.currentCart.cartItems[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCartTableViewCell", for: indexPath) as! CartViewCartTableViewCell
    cell.quantityLabel.text = String(cartItem.quantity)
    cell.nameLabel.text = cartItem.meal.name!
    cell.subTotalLabel.text = (Float(cartItem.quantity) * cartItem.meal.price!).currencyEUR
    return cell
  }
}

// MARK: - CLLocationManagerDelegate
extension CartViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if let location = locations.last {

      let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

      let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

      mapMapView.setRegion(region, animated: true)
    }
  }
}

// MARK: - UITextFieldDelegate
extension CartViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    if let address = textField.text {
      Cart.currentCart.deliveryAddress = address

      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in

        if let _error = error {
          print(_error.localizedDescription)
        }
        else
        {
          if let placemark = placemarks!.first {

            if let coordinate = placemark.location?.coordinate {

              let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

              self.mapMapView.setRegion(region, animated: true)
              self.locationMgr.stopUpdatingLocation()

              let dropPin = MKPointAnnotation()
              dropPin.coordinate = coordinate
              self.mapMapView.addAnnotation(dropPin)
            }
          }
        }
      })
    }

    return true
  }
}
