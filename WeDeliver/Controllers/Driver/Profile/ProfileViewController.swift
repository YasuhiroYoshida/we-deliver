//
//  ProfileViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import DropDown

class ProfileViewController: UIViewController {
  // MARK: - Vars
  let carDropdown = DropDown()
  let cars = ["Mazda": "car_1", "Tesla": "car_2", "Audi": "car_3"]

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var carDropdownButton: UIButton!
  @IBOutlet weak var updateProfileButton: UIButton!
  @IBOutlet weak var plateNumberTextfield: UITextField!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    loadDriver()
    loadCarsOntoDropdown()
  }

  private func loadDriver() {
    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(revealViewController().revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    if let imageURL = User.current.imageURL {
      Utils.fetchImage(from: imageURL, in: avatarImageView, round: true)
    }
    usernameLabel.text = User.current.name

    APIClient.shared.profile { json in
      if let driver_profile = json?["driver_profile"] {
        if let carModel = driver_profile["car_model"].string, self.cars.keys.contains(carModel) {
          self.carDropdownButton.setTitle(carModel, for: .normal)
          self.carImageView.image = UIImage(named: self.cars[carModel]!)
        }
        self.plateNumberTextfield.text = driver_profile["plate_number"].string!
      }
    }
  }

  private func loadCarsOntoDropdown() {
    carDropdown.anchorView = carDropdownButton
    carDropdown.dataSource = cars.keys.map { $0 }
    carDropdown.selectionAction = { [unowned self] (index: Int, carName: String) in
      carDropdownButton.setTitle(carName, for: .normal)
      carImageView.image = UIImage(named: cars[carName]!)
    }
  }

  // MARK: - IBActions
  @IBAction func selectCarButtonPressed(_ sender: Any) {
    carDropdown.show()
  }

  @IBAction func updateProfileButtonPressed(_ sender: Any) {
    guard let carModel = carDropdownButton.title(for: .selected), !carModel.isEmpty, let plateNumber = plateNumberTextfield.text, !plateNumber.isEmpty else {

      let alertController = UIAlertController(title: "Car model and plate number required", message: "You need to fill car model and plate number before taking an order.", preferredStyle: .alert)
      let action = UIAlertAction(title: "OK", style: .default)
      alertController.addAction(action)
      present(alertController, animated: true)
      return
    }

    APIClient.shared.updateProfile(carModel: carModel, plateNumber: plateNumber) { json in
      guard json?["driver_profile"] != nil else { return }

      self.plateNumberTextfield.resignFirstResponder()
      let alertController = UIAlertController(title: "????", message: "Update successful!", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default)
      alertController.addAction(okAction)
      self.present(alertController, animated: true)
    }
  }
}
