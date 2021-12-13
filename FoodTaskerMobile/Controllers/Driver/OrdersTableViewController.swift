//
//  OrdersTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit

class OrdersTableViewController: UITableViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  
  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath)

    return cell
  }
}
