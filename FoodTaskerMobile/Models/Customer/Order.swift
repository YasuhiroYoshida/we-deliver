//
//  Order.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-16.
//

import Foundation
import SwiftyJSON

struct Order {
  let id: Int
  let recipientName: String
  let recipientAvatar: String
  let recipientAddress: String
  let restaurantName: String
  let total: Float

  init(_ json: JSON) {
    self.id = json["id"].int!
    self.recipientName = json["customer"]["name"].string!
    self.recipientAvatar = json["customer"]["avatar"].string!
    self.recipientAddress = json["address"].string!
    self.restaurantName = json["restaurant"]["name"].string!
    self.total = json["total"].float!
  }
}
