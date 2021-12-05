//
//  RestaurantTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-05.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
  // MARK: - IBOutelets
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!

  // MARK: - View life cycle
  override func awakeFromNib() {
    super.awakeFromNib()

  }

  // MARK: - Protocols
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
