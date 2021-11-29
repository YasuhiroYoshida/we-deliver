//
//  RestaurantViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-28.
//

import UIKit

class RestaurantViewController: UIViewController {

  @IBOutlet weak var menuBarButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    menuBarButton.target = revealViewController()
    menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
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
