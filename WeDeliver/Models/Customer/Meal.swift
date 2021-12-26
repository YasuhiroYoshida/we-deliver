//
//  Meal.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-05.
//

import Foundation
import SwiftyJSON

struct Meal {
  var id: Int
  var name: String?
  var shortDescription: String?
  var image: String?
  var price: Float?

  init(_ json: JSON) {
    id = json["id"].int!
    name = json["name"].string
    shortDescription = json["short_description"].string
    image = json["image"].string
    price = json["price"].float
  }
}
