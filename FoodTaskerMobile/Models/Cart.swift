//
//  CartItem.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-07.
//

import Foundation

class Cart {
  static let currentCart = Cart()
  
  var restaurant: Restaurant?
  var deliveryAddress: String?
  var cartItems: [CartItem] = []
  var total: Float {
    var total: Float = 0.0
    for cartItem in cartItems {
      total += cartItem.meal.price! * Float(cartItem.quantity)
    }
    return total
  }
  var quantity: Int {
    return cartItems.reduce(0) { $0 + $1.quantity}
  }

  func reset(includingDeliveryAddress: Bool = true) {
    restaurant = nil
    if includingDeliveryAddress {
      deliveryAddress = nil
    }
    cartItems = []
  }
}

