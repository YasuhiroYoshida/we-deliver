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
import MapKit

class APIClient {
  static let shared = APIClient()

  let baseURL = URL(string: BaseURL)!
  var accessToken = ""
  var refreshToken = ""
  var expiredAt = Date()

  private init() {}

  // MARK: - Auth
  func logIn(_ characterType: CharacterType, completion: @escaping (Error?) -> Void) {
    let path = "api/social/convert-token/"
    let url = baseURL.appendingPathComponent(path)
    let params: [String: Any] = [
      "grant_type": "convert_token",
      "client_id": ClientID, // client == FB developer account
      "client_secret": ClientSecret,
      "backend": "facebook",
      "token": AccessToken.current!.tokenString,
      "character_type": characterType.rawValue
    ]

    AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

      switch response.result {
      case .success(let value):
        let json = JSON(value)
        self.accessToken = json["access_token"].string!
        self.refreshToken = json["refresh_token"].string!
        self.expiredAt = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
        completion(nil)
      case .failure(let error):
        completion(error as AFError)
      }
    }
  }

  func logOut(completion: @escaping (Error?) -> Void) {
    let path = "api/social/revoke-token/"
    let url = baseURL.appendingPathComponent(path)
    let params: [String: Any] = [
      "client_id": ClientID,
      "client_secret": ClientSecret,
      "token": AccessToken.current!.tokenString,
    ]

    AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error as AFError)
      }
    }
  }

  // Tokens are always updated whenever a non-auth request is made and they have become stale
  func refreshToken(completion: @escaping () -> Void) {
    let path = "api/social/refresh-token/"
    let url = baseURL.appendingPathComponent(path)
    let params: [String: Any] = [
      "access_token": accessToken,
      "refresh_token": refreshToken
    ]

    if Date() <= expiredAt {
      completion()
    } else {
      AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { resoponse in

        switch resoponse.result {
        case .success(let value):
          let json = JSON(value)
          self.accessToken = json["access_token"].string!
          self.expiredAt = Date().addingTimeInterval(TimeInterval(json["expires_in"].int!))
          completion()
        case .failure:
          print("Refreshing access token was necessary but failed")
        }
      }
    }
  }

  // MARK: - Non-Auth
  func request(by method: Alamofire.HTTPMethod, to path: String, with params: [String: Any]?, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (JSON?) -> Void) {

    let url = baseURL.appendingPathComponent(path)

    refreshToken {
      AF.request(url, method: method, parameters: params, encoding: encoding, headers: nil).responseJSON { response in
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

  // MARK: - Non-Auth - CUSTOMER
  func restaurants(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/restaurants/"
    request(by: .get, to: url, with: nil, completion: completion)
  }

  func meals(restaurantId: Int, completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/restaurants/\(restaurantId)/meals/"
    request(by: .get, to: url, with: nil, completion: completion)
  }

  func createPaymentIntent(nonZeroDecimalCurrency: Bool = true, completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/create_payment_intent/"
    let params: [String: Any] = [
      "access_token": accessToken,
      "total": nonZeroDecimalCurrency ? Int(Cart.current.total * 100) : Int(Cart.current.total),
    ]
    request(by: .post, to: url, with: params, completion: completion)
  }

  func createOrder(completion: @escaping (JSON?) -> Void) {
    if let order_details = try? Cart.current.cartItemsStringified {
      let url = "api/customer/create_order/"
      let params: [String: Any] = [
        "access_token": accessToken,
        "restaurant_id": (Cart.current.restaurant?.id)!,
        "address": Cart.current.deliveryAddress!,
        "order_details": order_details
      ]
      request(by: .post, to: url, with: params, completion: completion)
    }
    else {
      completion(nil) // an unlikely event
    }
  }

  func order(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/order/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }

  func orderStatus(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/order_status/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }

  func orderLocation(completion: @escaping (JSON?) -> Void) {
    let url = "api/customer/order_location/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }

  // MARK: - Non-Auth - DRIVER
  func delivery(completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/delivery/"
    let params = [
      "access_token": accessToken
    ]

    request(by: .get, to: url, with: params, completion: completion)
  }

  func profile(completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/profile/"
    let params = [
      "access_token": accessToken
    ]
    request(by: .get, to: url, with: params, completion: completion)
  }

  func unownedOrders(completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/unowned_orders/"
    request(by: .get, to: url, with: nil, completion: completion)
  }

  func updateLocation(_ location: CLLocationCoordinate2D, completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/update_location/"
    let params: [String: Any] = [
      "access_token": accessToken,
      "location": "\(location.latitude),\(location.longitude)"
    ]

    request(by: .patch, to: url, with: params, completion: completion)
  }

  func updateOrder(id orderID: Int, newStatus: OrderStatus, completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/update_order/"
    let params: [String: Any] = [
      "access_token": accessToken,
      "order_id": orderID,
      "status": newStatus.rawValue
    ]

    request(by: .patch, to: url, with: params, completion: completion)
  }

  func updateProfile(carModel: String, plateNumber: String, completion: @escaping (JSON?) -> Void) {
    let url = "api/driver/update_profile/"
    let params = [
      "access_token": accessToken,
      "car_model": carModel,
      "plate_number": plateNumber
    ]
    request(by: .patch, to: url, with: params, completion: completion)
  }
}
