//
//  ProfileViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit

class ProfileViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

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

  // MARK: - Navigation
}
