//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import UIKit
import FBSDKLoginKit
/*
Login procedure:
  1. Check if there is a user access token stored in the app, if so, keep it and change the title of the login button
  2. User presees the login button
    2-1. With the access token present, let the user log in and redirect to SWReveal
    2-2. With the access token missing, let the fb client
 */

class LoginViewController: UIViewController {
  // MARK: - Vars
  var userType: String = UserTypeCustomer

  // MARK: - IBOutlets
  @IBOutlet weak var userSegmentedControl: UISegmentedControl!
  @IBOutlet weak var loginButton: UIButton!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if (AccessToken.current != nil) {
      FBAuthClient.fetchUser {
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
    let selectedControlIndex = userSegmentedControl.selectedSegmentIndex
    switch selectedControlIndex {
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
        guard error == nil else { return }
        self.redirect2Home()
      }
    } else {
      FBAuthClient.shared.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
        guard error == nil else { return }

        FBAuthClient.fetchUser() {
          self.redirect2Home()
        } 
      }
    }
  }
}
