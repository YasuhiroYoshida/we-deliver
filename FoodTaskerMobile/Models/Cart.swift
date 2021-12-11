//
//  CartItem.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-07.
//

import Foundation
import SwiftUI

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
  var cartItemsStringified: String {
    get throws {
      let _cartItems = cartItems.map { ["meal_id": $0.meal.id!, "quantity": $0.quantity] }

      guard JSONSerialization.isValidJSONObject(_cartItems) else {
        throw RuntimeError("cartItems are not convertible to JSON")
      }

      let data: Data
      do {
        data = try JSONSerialization.data(withJSONObject: _cartItems, options: [])
      }  catch {
        throw RuntimeError(error.localizedDescription)
      }

      return String(data: data, encoding: String.Encoding.utf8)!
    }
  }

  func reset(includingDeliveryAddress: Bool = true) {
    restaurant = nil
    if includingDeliveryAddress {
      deliveryAddress = nil
    }
    cartItems = []
  }
}

