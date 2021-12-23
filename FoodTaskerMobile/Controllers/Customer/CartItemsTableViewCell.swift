//
//  CartItemsTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-08.
//

import UIKit

class CartItemsTableViewCell: UITableViewCell {
  // MARK: - IBOutlets
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var subTotalLabel: UILabel!
  @IBOutlet weak var quantityLabel: UILabel!

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
