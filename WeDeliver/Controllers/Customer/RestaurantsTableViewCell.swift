//
//  RestaurantsTableViewCell.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-05.
//

import UIKit

class RestaurantsTableViewCell: UITableViewCell {
  // MARK: - IBOutelets
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!

  // MARK: - Lifecycles
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  // MARK: - Protocols
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
