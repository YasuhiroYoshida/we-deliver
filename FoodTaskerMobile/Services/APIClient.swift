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
import SwiftUI

class APIClient {
  // MARK: - Vars
  static let shared = APIClient()

  let baseURL = URL(string: BaseURL)
  var accessToken = ""
  var refreshToken = ""
  var expirationDate = Date()

  // MARK: - Lifecycles
  private init() {}

  func logIn(_ userType: String, completion: @escaping (Error?) -> Void) {
    let path = "api/social/convert-token/"
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
      case .failure(let error):
        completion(error as Error)
      }
    }
  }

  func logOut(completion: @escaping (Error?) -> Void) {
    let path = "api/social/revoke-token/"
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
      case .failure(let error):
        completion(error as Error)
      }
    }
  }

  func refreshToken(completion: @escaping () -> Void) {
    let path = "api/social/refresh-token/"
    let url = baseURL?.appendingPathComponent(path)
    let params: [String: Any] = [
      "access_token": accessToken,
      "refresh_token": refreshToken
    ]

    if Date() > expirationDate {
      AF.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { resoponse in

        switch resoponse.result {
        case .success(let value):
          let json = JSON(value)
          self.accessToken = json["access_token"].string!
          self.expirationDate = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
          completion()
        case .failure:
          print("Refreshing access token was necessary but failed")
        }
      }
    } else {
      completion()
    }
  }

  func request(by method: Alamofire.HTTPMethod, to path: String, with params: [String: Any]?, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (JSON?) -> Void) {

    let url = baseURL?.appendingPathComponent(path)

    refreshToken {
      AF.request(url!, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON { response in
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          completion(json)
        case .failure(let error):
          print(error.localizedDescription)
          completion(nil)
        }
      }
    }
  }

  func restaurants(completion: @escaping (JSON?) -> Void) {
    request(by: .get, to: "api/customer/restaurants/", with: nil, completion: completion)
  }

  func meals(restaurantId: Int, completion: @escaping (JSON?) -> Void) {
    request(by: .get, to: "api/customer/restaurants/\(restaurantId)/meals/", with: nil, completion: completion)
  }

  func createPaymentIntent(nonZeroDecimalCurrency: Bool = true, completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/payment_intent/"
    let params: [String: Any] = [
      "access_token": accessToken,
      "total": nonZeroDecimalCurrency ? Int(Cart.currentCart.total * 100) : Int(Cart.currentCart.total),
    ]

    request(by: .post, to: url, with: params, completion: completion)
  }

  func createOrder(completion: @escaping (JSON?) -> Void) {

    if let order_details = try? Cart.currentCart.cartItemsStringified {
      let url = "api/customer/order/add/"
      let params: [String: Any] = [
        "access_token": accessToken,
        "restaurant_id": (Cart.currentCart.restaurant?.id)!,
        "address": Cart.currentCart.deliveryAddress!,
        "order_details": order_details
      ]
      request(by: .post, to: url, with: params, completion: completion)
    }
  }

  func findLatestOrder(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/order/latest/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }

  func findLatestOrderStatus(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/order/latest_status/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }
}
