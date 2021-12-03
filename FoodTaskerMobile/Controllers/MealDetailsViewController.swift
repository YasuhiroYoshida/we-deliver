//
//  MealDetailsViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit

class MealDetailsViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var minusButton: UIButton!
  @IBOutlet weak var plusButton: UIButton!

  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    minusButton.layer.cornerRadius = minusButton.frame.width / 2
    minusButton.layer.masksToBounds = true
    minusButton.layer.borderWidth = 1
    minusButton.layer.borderColor = UIColor.systemGray5.cgColor
    minusButton.backgroundColor = .clear

    plusButton.layer.cornerRadius = plusButton.frame.width / 2
    plusButton.layer.masksToBounds = true
    plusButton.layer.borderWidth = 1
    plusButton.layer.borderColor = UIColor.systemGray5.cgColor
    plusButton.backgroundColor = .clear

  }


  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */

}
