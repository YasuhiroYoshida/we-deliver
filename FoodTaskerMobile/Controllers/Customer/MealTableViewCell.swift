//
//  MealTableViewCell.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-05.
//

import UIKit

class MealTableViewCell: UITableViewCell {
  // MARK: - IBOutlets
  @IBOutlet weak var mealImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var shortDescriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!

  // MARK: - Lifecycles
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
