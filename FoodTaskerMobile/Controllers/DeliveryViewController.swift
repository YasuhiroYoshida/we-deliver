//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-01.
//

import UIKit

class DeliveryViewController: UIViewController {
  // MARK: - IBOutlet
  @IBOutlet weak var menuBarButton: UIBarButtonItem!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if self.revealViewController() != nil {
      menuBarButton.target = self.revealViewController()
      menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())

    }
  }
}
