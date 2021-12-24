//
//  OrdersTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-16.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {
  // MARK: - IBOutlets
  @IBOutlet weak var restaurantNameLabel: UILabel!
  @IBOutlet weak var recipientAvatarImageView: UIImageView!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var recipientNameLabel: UILabel!
  @IBOutlet weak var recipientAddressLabel: UILabel!

  // MARK: - Lifecycles
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}
