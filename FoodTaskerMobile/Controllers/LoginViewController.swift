//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
  var userType: String = UserTypeCustomer

  // MARK: - IBOutlets
  @IBOutlet weak var userSegmentedControl: UISegmentedControl!
  @IBOutlet weak var loginButton: UIButton!
  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if (AccessToken.current != nil) {
      MetaClient.fetchUser {
        self.loginButton.setTitle("Continue as \(User.current.name!)", for: .normal)
        self.loginButton.sizeToFit()
      }
    }
  }

  func redirect2Home() {
    if let token = AccessToken.current, !token.isExpired {
      switch userType {
      case UserTypeCustomer:
        performSegue(withIdentifier: "LoginView2SWRevealForCustomer", sender: self)
      case UserTypeDriver:
        performSegue(withIdentifier: "LoginView2SWRevealForDriver", sender: self)
      default:
        break
      }
    }
  }

  // MARK: - IBActions
  @IBAction func userSegmentedControlPressed(_ sender: Any) {
    let index = userSegmentedControl.selectedSegmentIndex
    switch index {
    case 0:
      userType = UserTypeCustomer
    case 1:
      userType = UserTypeDriver
    default:
      break
    }
  }

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
