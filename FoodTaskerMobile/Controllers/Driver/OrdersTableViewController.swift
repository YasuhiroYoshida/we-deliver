//
//  OrdersTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import SkeletonView

class OrdersTableViewController: UITableViewController {
  // MARK: - Vars
  var orders: [Order] = []

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var ordersTableView: UITableView!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    ordersTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete, secondaryColor: nil))
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    loadDriverAndOrders()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    Utils.stopTimers()
  }

  private func loadDriverAndOrders() {

    APIClient.shared.profile { json in
      if let driver_profile = json?["driver_profile"] {
        if !driver_profile["car_model"].string!.isEmpty && !driver_profile["plate_number"].string!.isEmpty {
          self.loadOrders()
        } else {
          let alertController = UIAlertController(title: "Car model and plate number required", message: "You will be taken to your profile.", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.performSegue(withIdentifier: "OrdersTableView2ProfileView", sender: self)
          }
          alertController.addAction(okAction)
          self.present(alertController, animated: true)
        }
      }

      self.ordersTableView.stopSkeletonAnimation()
      self.view.hideSkeleton()
    }
  }

  private func loadOrders() {
    APIClient.shared.unownedOrders { json in
      if let unowned_orders = json!["unowned_orders"].array {
        for unowned_order in unowned_orders {
          self.orders.append(Order(unowned_order))
        }
      }
      self.tableView.reloadData()
    }
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath) as! OrdersTableViewCell
    if let image = try? UIImage(data: Data(contentsOf: URL(string: orders[indexPath.row].recipientAvatar)!)) {
      cell.recipientAvatarImageView.image = image
    }
    cell.totalLabel.text = orders[indexPath.row].total.currencyEUR
    cell.recipientNameLabel.text = orders[indexPath.row].recipientName
    cell.recipientAddressLabel.text = orders[indexPath.row].recipientAddress
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let order = orders[indexPath.row]

    APIClient.shared.updateOrder(id: order.id, newStatus: .onTheWay) { json in

      switch json?["status"].string! {
      case "Success":
        let alertController = UIAlertController(title: "Success", message: "You have successfully picked the order 🚴💨", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
          self.performSegue(withIdentifier: "OrdersTableView2DeliveryView", sender: self)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true)
      case "Failure":
        let alertController = UIAlertController(title: "Error", message: json?["error"].string!, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
      default:
        break
      }
    }
  }
}
