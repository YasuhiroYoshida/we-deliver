//
//  MealsTableViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit
import SkeletonView

class MealsTableViewController: UITableViewController {
  // MARK: - Vars
  var restaurant: Restaurant!
  var meals: [Meal] = []
  var cartButton: UIButton!

  // MARK: - IBOutlets
  @IBOutlet weak var mealsTableView: UITableView!

  // MARK: - View Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = restaurant.name

    mealsTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete))

    loadMeals()
  }

  private func loadMeals() {
    APIClient.shared.meals(restaurantId: restaurant.id) { json in
      guard let _json = json else { return }

      for meal in _json["meals"].array! {
        self.meals.append(Meal(meal))
      }

      self.mealsTableView.stopSkeletonAnimation()
      self.view.hideSkeleton()
      self.mealsTableView.reloadData()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    initCartBbutton()
    updateCartButton()
  }

  private func initCartBbutton() {
    cartButton = UIButton(type: .custom)
    cartButton.backgroundColor = .black
    cartButton.translatesAutoresizingMaskIntoConstraints = false
    cartButton.isHidden = true
    cartButton.addTarget(self, action: #selector(goToCartView(_:)), for: .touchUpInside)

    DispatchQueue.main.async {
      self.tableView.addSubview(self.cartButton)
      self.cartButton.leadingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.leadingAnchor, constant: 20.0).isActive = true
      self.cartButton.trailingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.trailingAnchor, constant: -20.0).isActive = true
      self.cartButton.bottomAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
      self.cartButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
  }

  func updateCartButton() {
    let quantity = Cart.current.quantity
    cartButton.setTitle("View cart (\(quantity))", for: .normal)
    cartButton.isHidden = quantity == 0 ? true : false
  }

  // MARK: - IBActions
  // A connection will not be made between cartButton in storyboard and this function
  // cartButton will directly call this func
  @IBAction private func goToCartView(_ sender: Any) {
    performSegue(withIdentifier: "MealsTableView2CartView", sender: nil)
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

    let cell = tableView.dequeueReusableCell(withIdentifier: "MealsTableViewCell", for: indexPath) as! MealsTableViewCell
    if let imageURL = meal.image {
      Utils.fetchImage(in: cell.mealImageView, from: imageURL)
    }
    cell.nameLabel.text = meal.name
    cell.shortDescriptionLabel.text = meal.shortDescription
    cell.priceLabel.text = meal.price!.currencyEUR
    return cell
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MealsTableView2MealDetailsView" {
      let mealDetailsViewController = segue.destination as! MealDetailsViewController
      mealDetailsViewController.meal = meals[mealsTableView.indexPathForSelectedRow!.row]
      mealDetailsViewController.restaurant = restaurant
    }
  }
}

extension MealsTableViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "MealsTableViewCell"
  }
}
