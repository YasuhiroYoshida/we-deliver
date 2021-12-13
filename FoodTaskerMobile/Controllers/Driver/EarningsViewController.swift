//
//  EarningsViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit

class EarningsViewController: UIViewController {

  // MARK: - Vars
  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(revealViewController().revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
  }

 // MARK: - Navigation
}
