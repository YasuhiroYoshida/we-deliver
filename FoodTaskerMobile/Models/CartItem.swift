//
//  CartItem.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-07.
//

import Foundation

struct CartItem {
  var meal: Meal
  var quantity: Int

  init(_ meal: Meal, _ quantity: Int) {
    self.meal = meal
    self.quantity = quantity
  }
}
