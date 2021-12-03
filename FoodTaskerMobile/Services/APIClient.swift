//
//  APIClient.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class APIClient {
  static let shared = APIClient()

  let baseURL = URL(string: "localhost:8000/")
  var accessToken = ""
  var refreshToken = ""
  var expirationDate = Date()

  func logIn(_ userType: String, completion: @escaping (Error?) -> Void) {

  }

  func logOut(completion: @escaping (Error?) -> Void) {
    
  }
}
