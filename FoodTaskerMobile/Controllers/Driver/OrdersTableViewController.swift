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
  var driver: User?

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

    ordersTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .concrete, secondaryColor: nil))

    loadDriverAndOrders()
  }

  private func loadDriverAndOrders() {
    APIClient.shared.profile { json in

      if let driver_profile = json?["driver_profile"] {
        if !driver_profile["car_model"].string!.isEmpty && !driver_profile["plate_number"].string!.isEmpty {
          self.loadOrders()
        } else {
          let alertController = UIAlertController(title: "Car model and plate number required", message: "Please update your profile for your car model and plate number before taking an order.", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default)
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
    if let imageURL = orders[indexPath.row].customerAvatar {
      if let image = try? UIImage(data: Data(contentsOf: URL(string: imageURL)!)) {
        cell.customerAvatarImageView.image = image
      }
    }
    cell.totalLabel.text = orders[indexPath.row].total!.currencyEUR
    cell.customerNameLabel.text = orders[indexPath.row].customerName
    cell.customerAddressLabel.text = orders[indexPath.row].customerAddress
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let order = orders[indexPath.row]

    APIClient.shared.updateOrder(id: order.id!, newStatus: .onTheWay) { json in
      let _json = json!
      switch _json["status"].string {
      case "Success":
        let alertController = UIAlertController(title: "Success", message: "You have successfully picked the order.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
          self.performSegue(withIdentifier: "OrdersTableView2DriverDeliveryView", sender: self)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true)
      case "Failure":
        let alertController = UIAlertController(title: "Error", message: _json["error"].string, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
      default:
        break
      }
    }
  }
}
