//
//  NumberFormatter.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-06.
//

import Foundation

extension Formatter {
  static let shared = NumberFormatter()
}

extension Locale {
  static let englishUS = Locale.init(identifier: "en_US")
}

extension Numeric {
  var currency: String { formatted(style: .currency) }
  var currencyUSD: String { formatted(style: .currency, locale: .englishUS) }

  func formatted(style: NumberFormatter.Style, locale: Locale = .current) -> String {
    Formatter.shared.numberStyle = style
    Formatter.shared.locale = locale
    return Formatter.shared.string(for: self) ?? ""
  }
}

