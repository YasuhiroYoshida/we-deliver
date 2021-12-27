//
//  Env.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-27.
//

import Foundation

enum Env {
  enum Keys {
    enum Plist {
      static let baseURL = "BASE_URL"
      static let clientID = "CLIENT_ID"
      static let clientSecret = "CLIENT_SECRET"
      static let stripePublicKey = "STRIPE_PUBLIC_KEY"
    }
  }

  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("plist file not found")
    }
    return dict
  }()

  static let baseURL: String = {
    guard let url = Env.infoDictionary[Keys.Plist.baseURL] as? String else {
      fatalError("\(Keys.Plist.baseURL) has not been set in plist for this environment")
    }
    return url
  }()

  static let clientID: String = {
    guard let url = Env.infoDictionary[Keys.Plist.clientID] as? String else {
      fatalError("\(Keys.Plist.clientID) has not been set in plist for this environment")
    }
    return url
  }()

  static let clientSecret: String = {
    guard let url = Env.infoDictionary[Keys.Plist.clientSecret] as? String else {
      fatalError("\(Keys.Plist.clientSecret) has not been set in plist for this environment")
    }
    return url
  }()

  static let stripePublicKey: String = {
    guard let key = Env.infoDictionary[Keys.Plist.stripePublicKey] as? String else {
      fatalError("\(Keys.Plist.clientSecret) has not been set in plist for this environment")
    }
    return key
  }()
}
