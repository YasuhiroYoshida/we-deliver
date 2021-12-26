//
//  MealDetailsViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit

class MealDetailsViewController: UIViewController {
  // MARK: - Vars
  var restaurant: Restaurant!
  var meal: Meal!
  var quantity: Int = 1
  var subTotal: String {
    return (meal.price! * Float(quantity)).currencyEUR
  }

  // MARK: - Vars - Badge
  var badge = UILabel()
  var badgeBreadth: CGFloat = 24.0
  var badgeTag = 1_234_567_890 // a random number

  // MARK: - IBOutlets
  @IBOutlet weak var cartButton: UIButton!
  @IBOutlet weak var mealImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var shortDescriptionLabel: UILabel!
  @IBOutlet weak var minusButton: UIButton!
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var plusButton: UIButton!
  @IBOutlet weak var addToCartButton: UIButton!
  @IBOutlet weak var subTotalLabel: UILabel!

  func refreshBadge() {
    Utils.removeBadge(tag: badgeTag, from: cartButton) // reset it first

    let totalQuantityInCart = Cart.current.quantity
    let badgeText = String(totalQuantityInCart)
    badge = Utils.createBadge(text: badgeText, tag: badgeTag, breadth: badgeBreadth)

    if totalQuantityInCart > 0 {
      Utils.addBadge(&badge, to: &cartButton)
      cartButton.isEnabled = true
    } else {
      cartButton.isEnabled = false
    }
  }

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    initButtonsAndLabels()
    fetchMeal()
    refreshBadge()
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
    if let imageURL = meal.image {
      Utils.fetchImage(in: mealImageView, from: imageURL)
    }
    nameLabel.text = meal.name
    shortDescriptionLabel.text = meal.shortDescription
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

  // 3 possible behaviors depending on the state of the cart
  // Case 1. You cart is empty
  // Case 2. Your cart is filled with items from the current restaurant
  // Case 3. Your cart is filled with items from another restaurant
  @IBAction func addToCartPressed(_ sender: Any) {
    let thisCartItem = CartItem(meal, quantity)

    // Case 1. You cart is empty
    // Both restaurant and cartItems in cart starts out and remains nil until an item is added for the first time.
    // you only need to check either one of them to see if the cart is empty.
    // both properties are cleared when the cart is reset.
    if Cart.current.restaurant == nil {
      Cart.current.restaurant = restaurant
      Cart.current.cartItems.append(thisCartItem)
      goBackToMealsTableView()
      return
    }

    // Case 2. Your cart is filled with items from the current restaurant
    if Cart.current.restaurant?.id == restaurant.id {
      let foundAt = Cart.current.cartItems.firstIndex { cartItem in
        return cartItem.meal.id == thisCartItem.meal.id
      }

      // Case 2-1. Your cart is filled with the same item
      if let index = foundAt {
        let alertController = UIAlertController(
          title: "Add more?",
          message: "You already have this meal in your cart. Would you like to add more?",
          preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Add more?", style: .default) { action in
          Cart.current.cartItems[index].quantity += self.quantity
          self.goBackToMealsTableView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)

      // Case 2-2. Your cart is filled with other items
      } else {
        Cart.current.cartItems.append(thisCartItem)
        goBackToMealsTableView()
      }

    // Case 3. Your cart is filled with items from another restaurant
    } else {
      let alertController = UIAlertController(title: "Reset your cart?", message: "You already have meals from another restaurant in your cart. You can only have meals from one restaurant at a time.", preferredStyle: .alert)

      let okAction = UIAlertAction(title: "Reset cart", style: .default) { action in
        Cart.current.reset(includingDeliveryAddress: false)
        Cart.current.restaurant = self.restaurant
        Cart.current.cartItems.append(thisCartItem)
        self.goBackToMealsTableView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .default)

      alertController.addAction(okAction)
      alertController.addAction(cancelAction)
      present(alertController, animated: true)
    }
  }

  // MARK: - Navigation
  private func goBackToMealsTableView() {
    navigationController?.popViewController(animated: true)
  }
}
