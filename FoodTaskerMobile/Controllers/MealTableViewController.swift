//
//  MealTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-29.
//

import UIKit
import SkeletonView

class MealTableViewController: UITableViewController {
  // MARK: - Vars
  var restaurant: Restaurant?
  var meals: [Meal] = []

  // MARK: - IBOutlets
  @IBOutlet weak var mealTableView: UITableView!

  // MARK: - View Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = restaurant!.name

    mealTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete), animation: nil, transition: .crossDissolve(0.25))

    loadMeals()
  }

  private func loadMeals() {
    APIClient.shared.meals(restaurantId: restaurant!.id!) { json in
      guard json != nil else { return }

      for meal in json!["meals"].array! {
        self.meals.append(Meal(meal))
      }

      self.mealTableView.stopSkeletonAnimation()
      self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
      self.mealTableView.reloadData()
    }
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
    cell.priceLabel.text = String(format: "$ %.2f", meal.price!)
    return cell
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MealTableViewCell2MealDetail" {
      let mealDetailsVC = segue.destination as! MealDetailsViewController
      mealDetailsVC.meal = meals[mealTableView.indexPathForSelectedRow!.row]
    }
  }
}

extension MealTableViewController: SkeletonTableViewDataSource {
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "MealTableViewCell"
  }
}
