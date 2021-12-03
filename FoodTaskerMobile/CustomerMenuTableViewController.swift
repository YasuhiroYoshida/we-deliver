//
//  CustomerMenuTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit

class CustomerMenuTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var avatarView: UIImageView!

  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    usernameLabel.text = User.currentUser.name!
    if let image = try? UIImage(data: Data(contentsOf: URL(string: User.currentUser.pictureUrl!)!)) {
      avatarView.image = image
    }
    avatarView.layer.cornerRadius = avatarView.frame.width / 2
    avatarView.layer.borderWidth = 1
    avatarView.layer.borderColor = UIColor.white.cgColor
    avatarView.layer.masksToBounds = true
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Logout
    if segue.identifier == "Logout2Login" {
      MetaClient.shared.logOut() // AccessToken.current will be lost
      User.currentUser.resetAttrs()
    }
  }
}
