//
//  RestaurantsViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-11-28.
//

import UIKit
import SkeletonView
import SideMenu

class RestaurantsViewController: UIViewController {
  // MARK: - Vars
  var restaurants: [Restaurant] = []
  var filteredRestaurants: [Restaurant] = []

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var restaurantsTableView: UITableView!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.delegate = self

    restaurantsTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete))

    loadRestaurants()
  }

  private func loadRestaurants() {
    APIClient.shared.restaurants { json in
      guard let _json = json else { return }

      for restaurant in _json["restaurants"].array! {
        self.restaurants.append(Restaurant(restaurant))
      }

      self.restaurantsTableView.stopSkeletonAnimation()
      self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
      self.restaurantsTableView.reloadData()
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "RestaurantsView2MealTableView" {
      let mealsTableViewController = segue.destination as! MealsTableViewController
      mealsTableViewController.restaurant = restaurants[restaurantsTableView.indexPathForSelectedRow!.row]
    }
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RestaurantsViewController: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchBar.text!.isEmpty ? restaurants.count : filteredRestaurants.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let restaurant = searchBar.text!.isEmpty ? restaurants[indexPath.row] : filteredRestaurants[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantsTableViewCell", for: indexPath) as! RestaurantsTableViewCell
    cell.nameLabel.text = restaurant.name
    cell.addressLabel.text = restaurant.address
    if let logoURL = restaurant.logo {
      Utils.fetchImage(in: cell.logoImageView, from: logoURL)
    }
    return cell
  }
}

// MARK: - SkeletonTableViewDataSource
extension RestaurantsViewController: SkeletonTableViewDataSource {

  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "RestaurantsTableViewCell"
  }
}

// MARK: UISearchBarDelegate
extension RestaurantsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredRestaurants = restaurants.filter({ (restaurant) -> Bool in
      return restaurant.name?.lowercased().range(of: searchText.lowercased()) != nil
    })

    restaurantsTableView.reloadData()
  }
}
