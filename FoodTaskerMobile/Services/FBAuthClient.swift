//
//  FBAuthClient.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBAuthClient {
  static let shared = LoginManager()
  private init() {}
  
  class func authenticateUser(permissions: [String], from fromViewController: UIViewController?, handler: LoginManagerLoginResultBlock? = nil) {
    shared.logIn(permissions: permissions, from: fromViewController, handler: handler)
  }
  
  class func fetchUser(completion: @escaping () -> Void) {
    if let token = AccessToken.current, !token.isExpired {
      GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { isConnecting, result, error in
        guard error == nil else { return }
        
        let json = JSON(result!)
        User.current.setAttrs(json)
        completion()
      }
    }
  }
}
