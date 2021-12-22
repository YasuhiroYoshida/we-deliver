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

  static func removeBadge(tag: Int, from button: UIButton) {
    if let badgeLabel = button.viewWithTag(tag) as? UILabel {
      badgeLabel.removeFromSuperview()
    }
  }

  static func createBadge(text: String = "", tag: Int = 0, breadth: CGFloat) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: breadth, height: breadth))
    label.tag = tag
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.layer.masksToBounds = true
    label.backgroundColor = .greenSea
    label.text = text
    label.textAlignment = .center
    label.textColor = .white
    label.font = label.font.withSize(12)
    return label
  }

  static func addBadge(_ badge: inout UILabel, to button: inout UIButton) {
    button.addSubview(badge)

    NSLayoutConstraint.activate([
      badge.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 14.0),
      badge.topAnchor.constraint(equalTo: button.topAnchor, constant: -6.0),
      badge.widthAnchor.constraint(equalToConstant: badge.bounds.size.width),
      badge.heightAnchor.constraint(equalToConstant: badge.bounds.size.height),
    ])
  }
}
