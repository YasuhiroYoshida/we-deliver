//
//  CustomerMenuTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit

class CustomerMenuTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var avatarView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if let image = try? UIImage(data: Data(contentsOf: URL(string: User.current.pictureURL!)!)) {
      avatarView.image = image
    }
    avatarView.layer.cornerRadius = avatarView.frame.width / 2
    avatarView.layer.borderWidth = 1
    avatarView.layer.borderColor = UIColor.white.cgColor
    avatarView.layer.masksToBounds = true
    usernameLabel.text = User.current.name!
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "CustomerLogout2LoginView" {
      APIClient.shared.logOut { error in
        if error == nil {
          MetaClient.shared.logOut() // AccessToken.current will be lost
          User.current.resetAttrs()

          self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        }
      }
    }
  }
}
