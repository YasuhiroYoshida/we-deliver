//
//  PaymentViewController.swift
//  Pods
//
//  Created by Yasuhiro Yoshida on 2021-12-02.
//

import UIKit
import Lottie
//import Stripe

class PaymentViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var animationView: AnimationView!
//  @IBOutlet weak var cardTextField: STPPaymentCardTextField!

  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    animationView.contentMode = .scaleAspectFit
//    animationView.loo
//    cardTextField.postalCodeEntryEnabled = false
  }
}
