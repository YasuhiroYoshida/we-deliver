//
//  MealDetailsViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit

class MealDetailsViewController: UIViewController {
  // MARK: - Vars
  var meal: Meal?
  var quantity: Int = 99
  var subTotal: String {
    return (meal!.price! * Float(quantity)).currencyUSD
  }

  // MARK: - IBOutlets
  @IBOutlet weak var mealImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var shortDescriptionLabel: UILabel!
  @IBOutlet weak var minusButton: UIButton!
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var plusButton: UIButton!
  @IBOutlet weak var addToCartButton: UIButton!
  @IBOutlet weak var subTotalLabel: UILabel!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    initButtonsAndLabels()
    fetchMeal()
  }

  private func initButtonsAndLabels() {
    minusButton.layer.cornerRadius = minusButton.frame.width / 2
    minusButton.layer.masksToBounds = true
    minusButton.layer.borderWidth = 1
    minusButton.layer.borderColor = UIColor.systemGray5.cgColor
    minusButton.backgroundColor = .clear

    quantityLabel.text = String(quantity)

    plusButton.layer.cornerRadius = plusButton.frame.width / 2
    plusButton.layer.masksToBounds = true
    plusButton.layer.borderWidth = 1
    plusButton.layer.borderColor = UIColor.systemGray5.cgColor
    plusButton.backgroundColor = .clear

    subTotalLabel.text = subTotal
  }

  private func fetchMeal() {
    if let imageURL = meal?.image {
      Utils.fetchImage(in: mealImageView, from: imageURL)
    }
    nameLabel.text = meal?.name
    shortDescriptionLabel.text = meal?.shortDescription
  }

  // MARK: - IBActions
  @IBAction func minusButtonPressed(_ sender: Any) {
    decreaseQuantity()
  }
  private func decreaseQuantity() {
    guard quantity > 0 else { return }

    quantity -= 1
    quantityLabel.text = String(quantity)
    addToCartButton.setTitle("Add \(quantity) to Cart", for: .normal)
    subTotalLabel.text = subTotal
  }

  @IBAction func plusButtonPressed(_ sender: Any) {
    guard quantity < 99 else { return }

    quantity += 1
    quantityLabel.text = String(quantity)
    addToCartButton.setTitle("Add \(quantity) to Cart", for: .normal)
    subTotalLabel.text = subTotal
  }

  @IBAction func addToCartPressed(_ sender: Any) {
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
