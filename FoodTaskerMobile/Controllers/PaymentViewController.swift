//
//  PaymentViewController.swift
//  FoodTaskerMobile
//
//  Created by Yasuhiro Yoshida on 2021-12-02.
//

import UIKit
import Lottie
import Stripe
import SwiftyJSON

class PaymentViewController: UIViewController {
  // MARK: - Vars
  var paymentIntentSecret: String?

  // MARK: - IBOutlets
  @IBOutlet weak var animationView: AnimationView!
  @IBOutlet weak var cardTextField: STPPaymentCardTextField!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    animationView.animation = Animation.named("27630-credit-card-blue")
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    animationView.animationSpeed = 0.5
    animationView.play()

    cardTextField.postalCodeEntryEnabled = false

    fetchPaymentIntentSecret()
  }

  private func fetchPaymentIntentSecret() {
    APIClient.shared.createPaymentIntent { json in
      self.paymentIntentSecret = json?["client_secret"].string
    }
  }

  // MARK: - IBActions
  @IBAction func placeOrderButtonPressed(_ sender: Any) {

    APIClient.shared.findLatestOrder { json in
      print("あ", json)
      if json!["latest_order"]["restaurant"]["name"] == "" // user has never placed an order or,
          || json!["latest_order"]["status"] == "DELIVERED" { // user has no outstanding order

        guard let paymentIntentSecret = self.paymentIntentSecret else {
          return
        }

        let cardParams = self.cardTextField.cardParams
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams

        STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { status, intent, error in
          switch status {
          case .succeeded:
            print("Payment succeeded: \(intent?.description ?? "")")
            APIClient.shared.createOrder { json in
              print(json!)
              Cart.currentCart.reset()
              self.performSegue(withIdentifier: "PaymentView2DeliveryView", sender: self)
            }
          case .canceled:
            print("Payment canceled: \(error?.localizedDescription ?? "")")
          case .failed:
            print("Payment failed: \(error?.localizedDescription ?? "")")
          }
        }
      }
      else
      {
        let alertController = UIAlertController(title: "Last order still in progress", message: "A new order cannot be accepted before your last order is fulfilled. Would you like to see the last order?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
          self.performSegue(withIdentifier: "PaymentView2DeliveryView", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true)
      }
    }
  }
}

extension PaymentViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}
