//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
  let userType = UserTypeCustomer

  // MARK: - IBOutlets
  @IBOutlet weak var loginButton: UIButton!
  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if (AccessToken.current != nil) {
      MetaClient.fetchUser {
        self.loginButton.setTitle("Continue as \(User.currentUser.name!)", for: .normal)
        self.loginButton.sizeToFit()
      }
    }
  }

  func redirect2Home() {
    if let token = AccessToken.current, !token.isExpired {
      performSegue(withIdentifier: "Login2SWReveal", sender: self)
    }
  }

  // MARK: -
  @IBAction func loginButtonPressed(_ sender: Any) {
    if AccessToken.current != nil {
      APIClient.shared.logIn(userType) { error in
        if error == nil {
          self.redirect2Home()
        }
      }
    } else {
      MetaClient.shared.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
        if error == nil {
          MetaClient.fetchUser() {
            APIClient.shared.logIn(self.userType) { error in
              if error == nil {
                self.redirect2Home()
              }
            }
          }
        } 
      }
    }
  }
}
