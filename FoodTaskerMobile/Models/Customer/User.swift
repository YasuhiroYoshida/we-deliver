//
//  User.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-03.
//

import Foundation
import SwiftyJSON

struct User {
  var name: String?
  var email: String?
  var pictureURL: String?

  static var current = User()

  mutating func setAttrs(_ json: JSON) {
    self.name = json["name"].string
    self.email = json["email"].string
    let picture = json["picture"].dictionary
    let data = picture?["data"]?.dictionary
    self.pictureURL = data?["url"]?.string
  }

  mutating func resetAttrs() {
    self.name = nil
    self.email = nil
    self.pictureURL = nil
  }
}
