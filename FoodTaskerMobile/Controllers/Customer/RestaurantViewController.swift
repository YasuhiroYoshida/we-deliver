//
//  RestaurantViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-28.
//

import UIKit
import SkeletonView

class RestaurantViewController: UIViewController {
  // MARK: - Vars
  var restaurants: [Restaurant] = []
  var filteredRestaurants: [Restaurant] = []

  // MARK: - IBOutlets
  @IBOutlet weak var restaurantTableView: UITableView!
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    searchBar.delegate = self

    restaurantTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete), animation: nil, transition: .crossDissolve(0.25))

    loadRestaurants()
  }

  private func loadRestaurants() {
    APIClient.shared.restaurants { json in
      guard json != nil else { return }

      for restaurant in json!["restaurants"].array! {
        self.restaurants.append(Restaurant(restaurant))
      }

      self.restaurantTableView.stopSkeletonAnimation()
      self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
      self.restaurantTableView.reloadData()
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "Restaurant2Meals" {
      let mealVC = segue.destination as! MealTableViewController
      mealVC.restaurant = restaurants[restaurantTableView.indexPathForSelectedRow!.row]
    }
  }
}

extension RestaurantViewController: SkeletonTableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchBar.text!.isEmpty ? restaurants.count : filteredRestaurants.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let restaurant = searchBar.text!.isEmpty ? restaurants[indexPath.row] : filteredRestaurants[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell", for: indexPath) as! RestaurantTableViewCell
    cell.nameLabel.text = restaurant.name
    cell.addressLabel.text = restaurant.address
    if let logoURL = restaurant.logo {
      Utils.fetchImage(in: cell.logoImageView, from: logoURL)
    }
    return cell
  }

  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "RestaurantTableViewCell"
  }
}

extension RestaurantViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredRestaurants = restaurants.filter({ (restaurant) -> Bool in
      return restaurant.name?.lowercased().range(of: searchText.lowercased()) != nil
    })

    restaurantTableView.reloadData()
  }
}
