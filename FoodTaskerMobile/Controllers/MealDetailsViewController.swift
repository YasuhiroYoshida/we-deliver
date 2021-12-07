//
//  MealDetailsViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit

class MealDetailsViewController: UIViewController {
  // MARK: - Vars
  var restaurant: Restaurant?
  var meal: Meal?
  var quantity: Int = 1
  var subTotal: String {
    return (meal!.price! * Float(quantity)).currencyUSD
  }

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

  // MARK: - Badge
  var badgeLabel = UILabel()
  var badgeBreadth: CGFloat = 24.0
  var badgeTag = 9830384

  func createBadgeLabel(_ count: Int) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: badgeBreadth, height: badgeBreadth))
    label.tag = badgeTag
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.layer.masksToBounds = true
    label.backgroundColor = .greenSea
    label.text = String(count)
    label.textAlignment = .center
    label.textColor = .white
    label.font = label.font.withSize(12)
    return label
  }

  func showBadgeLabel() {
    cartButton.addSubview(badgeLabel)
    NSLayoutConstraint.activate([
      badgeLabel.leftAnchor.constraint(equalTo: cartButton.leftAnchor, constant: 14.0),
      badgeLabel.topAnchor.constraint(equalTo: cartButton.topAnchor, constant: -6.0),
      badgeLabel.widthAnchor.constraint(equalToConstant: badgeBreadth),
      badgeLabel.heightAnchor.constraint(equalToConstant: badgeBreadth),
    ])
  }

  func removeBadgeLabel() {
    if let badgeLabel = cartButton.viewWithTag(badgeTag) {
      badgeLabel.removeFromSuperview()
    }
  }

  func refreshBadgeLabel() {
    removeBadgeLabel()

    let quantity = Cart.currentCart.quantity
    badgeLabel = createBadgeLabel(quantity)

    if quantity > 0 {
      showBadgeLabel()
      cartButton.isEnabled = true
    } else {
      cartButton.isEnabled = false
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MealDetails2Cart" {
      let cartVC = segue.destination as! CartViewController
      performSegue(withIdentifier: "MealDetails2Cart", sender: self)
    }
  }

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    initButtonsAndLabels()
    fetchMeal()
    refreshBadgeLabel()
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
    let thisCartItem = CartItem(meal!, quantity)

    // Case 1. You cart is empty
    // restaurant in cart remains nil and cartItems in cart remains empty until an item is added for the first time.
    // you only need to check either one of them to see if the cart is empty.
    // both properties are cleared when the cart is reset.
    if Cart.currentCart.restaurant == nil {
      Cart.currentCart.restaurant = restaurant
      Cart.currentCart.cartItems.append(thisCartItem)
      goBackToMealTableView()
      return
    }

    // Case 2. Your cart is filled with items from the current restaurant
    if Cart.currentCart.restaurant!.id! == restaurant!.id {
      let foundAt = Cart.currentCart.cartItems.lastIndex { cartItem in
        return cartItem.meal.id == thisCartItem.meal.id
      } // can be firstIndex as there is no meal id that is redundant

      // Case 2-1. Your cart is filled with the same item
      if let index = foundAt {
        let alertController = UIAlertController(
          title: "Add more?",
          message: "You already have this meal in your cart. Would you like to add more?",
          preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Add more?", style: .default) { action in
          Cart.currentCart.cartItems[index].quantity += self.quantity
          self.goBackToMealTableView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
        // Case 2-2. Your cart is filled with other items
      } else {
        Cart.currentCart.cartItems.append(thisCartItem)
        goBackToMealTableView()
      }

      // Case 3. Your cart is filled with items from another restaurant
    } else {
      let alertController = UIAlertController(title: "Reset your cart?", message: "You already have meals from another restaurant in your cart. Would you like to reset your cart?", preferredStyle: .alert)

      let okAction = UIAlertAction(title: "Reset cart", style: .default) { action in
        Cart.currentCart.reset(includingDeliveryAddress: false)
        Cart.currentCart.restaurant = self.restaurant
        Cart.currentCart.cartItems.append(thisCartItem)
        self.goBackToMealTableView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .default)

      alertController.addAction(okAction)
      alertController.addAction(cancelAction)
      present(alertController, animated: true)
    }
  }

  // MARK: - Navigation
  private func goBackToMealTableView() {
    navigationController?.popViewController(animated: true)
  }
}
