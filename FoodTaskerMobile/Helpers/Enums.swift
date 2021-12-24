//
//  Enums.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-12.
//

import Foundation

enum OrderStatus: String {
  case cooking = "Cooking"
  case ready = "Ready"
  case onTheWay = "On the way"
  case delivered = "Delivered"
}

enum CharacterType: String {
  case Recipient, Driver, Restaurant
}
