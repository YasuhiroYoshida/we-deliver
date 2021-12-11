//
//  Errors.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-10.
//

import Foundation

struct RuntimeError: Error {
  let message: String
  init(_ message: String) {
    self.message = message
  }
  public var localizedDescription: String {
    return message
  }
}
