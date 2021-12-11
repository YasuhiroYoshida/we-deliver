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
  static let englishEE = Locale.init(identifier: "en_EE")
}

extension Numeric {
  var currency: String { formatted(style: .currency) }
  var currencyUSD: String { formatted(style: .currency, locale: .englishUS, currencySymbol: "$", currencyGroupingSeparator: ",", currencyDecimalSeparator: ".") }
  var currencyEUR: String { formatted(style: .currency, locale: .englishEE) }

  func formatted(style: NumberFormatter.Style, locale: Locale = .current, usesSignificantDigits: Bool = true, currencySymbol: String = "€", currencyGroupingSeparator: String = ".", currencyDecimalSeparator: String = ",") -> String {
    Formatter.shared.numberStyle = style
    Formatter.shared.locale = locale
//    Formatter.shared.usesSignificantDigits = usesSignificantDigits
    Formatter.shared.currencySymbol = currencySymbol
    Formatter.shared.currencyGroupingSeparator = currencyGroupingSeparator
    Formatter.shared.currencyDecimalSeparator = currencyDecimalSeparator
    return Formatter.shared.string(for: self) ?? ""
  }
}

