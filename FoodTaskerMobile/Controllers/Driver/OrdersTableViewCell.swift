//
//  OrdersTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-16.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {
  // MARK: - IBOutlets
  @IBOutlet weak var customerAvatarImageView: UIImageView!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var customerNameLabel: UILabel!
  @IBOutlet weak var customerAddressLabel: UILabel!

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
