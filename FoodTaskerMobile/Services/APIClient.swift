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

  let baseURL = URL(string: BaseURL)
  var accessToken = ""
  var refreshToken = ""
  var expirationDate = Date()

  func logIn(_ userType: String, completion: @escaping (Error?) -> Void) {
    let path = "api/social/convert-token"
    let url = baseURL?.appendingPathComponent(path)
    let params: [String: Any] = [
      "grant_type": "convert_token",
      "client_id": ClientID,
      "client_secret": ClientSecret,
      "backend": "facebook",
      "token": AccessToken.current!.tokenString,
      "user_type": userType
    ]

    AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

      switch response.result {
      case .success(let value):
        let json = JSON(value)
        self.accessToken = json["access_token"].string!
        self.refreshToken = json["refresh_token"].string!
        self.expirationDate = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
        completion(nil)
        break
      case .failure(let error):
        completion(error as Error)
        break
      }
    }
  }

  func logOut(completion: @escaping (Error?) -> Void) {
    let path = "api/social/revoke-token"
    let url = baseURL?.appendingPathComponent(path)
    let params: [String: Any] = [
      "client_id": ClientID,
      "client_secret": ClientSecret,
      "token": accessToken,
    ]

    AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

      switch response.result {
      case .success:
        completion(nil)
        break
      case .failure(let error):
        completion(error as Error)
        break
      }
    }
  }

  func refreshToken(completion: @escaping () -> Void) {
    let path = "api/social/refresh-token"
    let url = baseURL?.appendingPathComponent(path)
    let params: [String: Any] = [
      "access_token": accessToken,
      "refresh_token": refreshToken
    ]

    if Date() > expirationDate {
      AF.request(url!  , method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { resoponse in

        switch resoponse.result {
        case .success(let value):
          let json = JSON(value)
          self.accessToken = json["access_token"].string!
          self.expirationDate = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
          break
        case .failure:
          print("Refreshing access token was necessary but failed")
          break
        }
      }
    }

    completion()
  }

  func restaurants(completion: @escaping (JSON?) -> Void) {
    let path = "api/customer/restaurants/"
    let url = baseURL?.appendingPathComponent(path)

    refreshToken {
      AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          completion(json)
          break
        case .failure(let error):
          print(error.localizedDescription)
          completion(nil)
          break
        }
      }
    }
  }
}
