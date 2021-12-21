//
//  MealsTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit
import SkeletonView

class MealsTableViewController: UITableViewController {
  // MARK: - Vars
  var restaurant: Restaurant?
  var meals: [Meal] = []
  var cartButton: UIButton?

  // MARK: - IBOutlets
  @IBOutlet weak var mealTableView: UITableView!

  // MARK: - View Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = restaurant!.name

    mealTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete))

    loadMeals()
    initCartBbutton()
  }

  private func loadMeals() {
    APIClient.shared.meals(restaurantId: restaurant!.id!) { json in
      guard json != nil else { return }

      for meal in json!["meals"].array! {
        self.meals.append(Meal(meal))
      }

      self.mealTableView.stopSkeletonAnimation()
      self.view.hideSkeleton()
      self.mealTableView.reloadData()
    }
  }

  private func initCartBbutton() {
    cartButton = UIButton(type: .custom)
    cartButton?.backgroundColor = .black
    cartButton?.translatesAutoresizingMaskIntoConstraints = false
    cartButton?.isHidden = true
    cartButton?.addTarget(self, action: #selector(goToCart(_:)), for: .touchUpInside)

    DispatchQueue.main.async {
      self.tableView.addSubview(self.cartButton!)
      self.cartButton?.leadingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.leadingAnchor, constant: 20.0).isActive = true
      self.cartButton?.trailingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.trailingAnchor, constant: -20.0).isActive = true
      self.cartButton?.bottomAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
      self.cartButton?.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateCartButton()
  }

  func updateCartButton() {
    let quantity = Cart.currentCart.quantity
    cartButton?.setTitle("View cart (\(quantity))", for: .normal)
    cartButton?.isHidden = quantity == 0 ? true : false
  }

  // MARK: - IBActions
  @IBAction private func goToCart(_ sender: Any) {
    performSegue(withIdentifier: "MealTableView2CartView", sender: nil)
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return meals.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let meal = meals[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as! MealTableViewCell
    if let imageURL = meal.image {
      Utils.fetchImage(in: cell.mealImageView, from: imageURL)
    }
    cell.nameLabel.text = meal.name
    cell.shortDescriptionLabel.text = meal.shortDescription
//    cell.priceLabel.text = String(format: "$ %.2f", meal.price!)
    cell.priceLabel.text = meal.price!.currencyEUR
    return cell
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MealTableView2MealDetailsView" {
      let mealDetailsVC = segue.destination as! MealDetailsViewController
      mealDetailsVC.meal = meals[mealTableView.indexPathForSelectedRow!.row]
      mealDetailsVC.restaurant = restaurant
    }
  }
}

extension MealsTableViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "MealTableViewCell"
  }
}
