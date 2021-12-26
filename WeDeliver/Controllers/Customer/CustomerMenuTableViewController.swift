//
//  CustomerMenuTableViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit
import SideMenu

class CustomerMenuTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if let image = try? UIImage(data: Data(contentsOf: URL(string: User.current.imageURL!)!)) { // ✅
      avatarImageView.image = image
    }
    avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    avatarImageView.layer.borderWidth = 1
    avatarImageView.layer.borderColor = UIColor.white.cgColor
    avatarImageView.layer.masksToBounds = true
    usernameLabel.text = User.current.name!
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "CustomerMenuTableViewLogout2LoginView" {
      APIClient.shared.logOut { error in
        guard error == nil else { return }

        FBAuthClient.shared.logOut() // AccessToken.current will be lost
        User.current.resetAttrs()

        self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
      }
    }
  }
}
