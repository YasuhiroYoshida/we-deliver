//
//  CartViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-11-30.
//

import UIKit

class CartViewController: UIViewController {

  @IBOutlet weak var menuBarButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let controller = revealViewController() {
      menuBarButton.target = controller
      menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
      view.addGestureRecognizer(controller.panGestureRecognizer())
    }
  }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath)

    return cell
  }
}
