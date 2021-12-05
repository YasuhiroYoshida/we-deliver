//
//  Utils.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-05.
//

import Foundation

struct Utils {
  static func fetchImage(in imageView: UIImageView, from url: String) {
    guard let url = URL(string: url) else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let _data = data, error == nil else { return }

      DispatchQueue.main.async {
        imageView.image = UIImage(data: _data)
      }
    }.resume()
  }
}
