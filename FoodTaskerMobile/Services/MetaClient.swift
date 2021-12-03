//
//  MetaAuth.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class MetaClient {
  static let shared = LoginManager()

  public class func fetchUser(completion: @escaping () -> Void) {

    if let token = AccessToken.current, !token.isExpired {
      GraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { isConnecting, result, error in

        if error == nil {
          let json = JSON(result!)
          User.currentUser.setAttrs(json)
          completion()
        } else {
          DispatchQueue.main.async {
//            completion(error)
          }
        }
      }
    }
  }
}
