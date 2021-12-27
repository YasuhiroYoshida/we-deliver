//
//  Timers.swift
//  WeDeliever
//
//  Created by Yasuhiro Yoshida on 2021-12-27.
//

import Foundation

struct Timers {
  static var locationTimer: Timer?
  static var statusTimer: Timer?

  static func stopAll() {
    if locationTimer != nil {
      print("stopAll() locationTimer")
      locationTimer!.invalidate()
      locationTimer = nil
    }
    if statusTimer != nil {
      print("stopAll() statusTimer")
      statusTimer!.invalidate()
      statusTimer = nil
    }
  }
}
