//
//  RestaurantViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-28.
//

import UIKit

class RestaurantViewController: UIViewController {
  // MARK: - Vars
  var restaurants: [Restaurant] = []

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButton: UIBarButtonItem!

  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButton.target = revealViewController()
      menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    loadRestaurants()

  }

  private func loadRestaurants() {
    APIClient.shared.restaurants { responseAsJson in
      if let json = responseAsJson {
        for restaurant in json["restaurants"].array! {
          self.restaurants.append(Restaurant(restaurant))
        }
      }
    }
  }
}

extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return 3
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     // Fetch a cell of the appropriate type.
     let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)

     // Configure the cell’s contents.
     cell.textLabel!.text = "Cell text"

     return cell
  }
}
