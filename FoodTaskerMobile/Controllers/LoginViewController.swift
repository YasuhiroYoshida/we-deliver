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
    1. With the access token present, communicate with FB and get updated tokens
      1. Error: Nothing further, NO LOGIN ☠️
      2. Success: Update tokens both in the cache and APIClient
        1. If customer, let the customer land on restaurants view
        2. If driver, let the driver land on orders table view
    2. With the access token missing, let the fb client authenticate the user through the social auth
      1. Errors: Nothing further, NO LOGIN ☠️
      2. Success: Store tokens in the cache
        1. Access token is validated
          1. Errors: Nothing further, NO LOGIN ☠️
          2. Success: User info is fetched from FB
            1. Errors: Nothing further, NO LOGIN ☠️
            2. Success: Current user is set with the fetched info
              - APIClient will not be given updated tokens here. They will be checked and renewed every time non-auth request is made from here onwards.
              1. If customer, let the customer land on restaurants view
              2. If driver, let the driver land on orders table view
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

  func redirect() {
    if let token = AccessToken.current, !token.isExpired {
      switch userType {
      case UserTypeCustomer:
        let destinationView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestaurantsViewNavigationController") as! UINavigationController
        destinationView.modalPresentationStyle = .fullScreen
        self.present(destinationView, animated: true, completion: nil)
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
        self.redirect()
      }
    }
    else {
      FBAuthClient.authenticateUser(permissions: ["public_profile", "email"], from: self) { result, error in
        guard error == nil else { return }

        FBAuthClient.fetchUser() {
          self.redirect()
        } 
      }
    }
  }
}
