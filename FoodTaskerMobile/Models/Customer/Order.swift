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
  let customerName: String
  let customerAvatar: String
  let customerAddress: String
  let restaurantName: String
  let total: Float

  init(_ json: JSON) {
    self.id = json["id"].int!
    self.customerName = json["customer"]["name"].string!
    self.customerAvatar = json["customer"]["avatar"].string!
    self.customerAddress = json["address"].string!
    self.restaurantName = json["restaurant"]["name"].string!
    self.total = json["total"].float!
  }
}
