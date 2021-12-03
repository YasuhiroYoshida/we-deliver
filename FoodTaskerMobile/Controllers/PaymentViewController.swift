//
//  PaymentViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-02.
//

import UIKit
import Lottie
import Stripe

class PaymentViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var animationView: AnimationView!
  @IBOutlet weak var cardTextField: STPPaymentCardTextField!

  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    animationView.animation = Animation.named("27630-credit-card-blue")

    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    animationView.animationSpeed = 0.5
    animationView.play()

    cardTextField.postalCodeEntryEnabled = false
  }
}
