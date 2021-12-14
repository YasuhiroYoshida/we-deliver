//
//  ProfileViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import DropDown

class ProfileViewController: UIViewController {
  // MARK: - Vars
  let carDropdown = DropDown()
  let cars = ["Mazda": "car_1", "Honda": "car_2", "Chevrolet": "car_3"]

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

    if let imageURL = User.current.pictureURL {
      if let image = try? UIImage(data: Data(contentsOf: URL(string: imageURL)!)) {
        avatarImageView.image = image
      }
      avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
      avatarImageView.layer.borderColor = UIColor.white.cgColor
      avatarImageView.layer.borderWidth = 1
      avatarImageView.clipsToBounds = true
    }
    usernameLabel.text = User.current.name
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
  }

  // MARK: - Navigation
}
