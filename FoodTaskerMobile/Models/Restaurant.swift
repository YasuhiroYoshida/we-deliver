//
//  Restaurant.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-04.
//

import Foundation
import SwiftyJSON

struct Restaurant {
  var id: Int?
  var name: String?
  var address: String?
  var logo: String?

  init(_ json: JSON) {
    id = json["id"].int
    name = json["name"].string
    address = json["address"].string
    logo = json["logo"].string
  }
}
