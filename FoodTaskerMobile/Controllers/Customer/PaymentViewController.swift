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
    guard paymentIntentSecret != nil else {
      let alertController = UIAlertController(title: "Payment cannot be processed this time", message: "Please try again later", preferredStyle: .alert)
      let action = UIAlertAction(title: "OK", style: .cancel)
      alertController.addAction(action)
      present(alertController, animated: true)
      return
    }

    APIClient.shared.order { json in
      // 1 of the 2 conditions below has to be met before proceeding:
      // User has never placed an order -> created_at must be nil
      // User has has an order that has already been delivered -> status is "Delivered"
      guard (json?["order"]["created_at"].string == nil || json?["order"]["status"].string == OrderStatus.delivered.rawValue) else {

        let alertController = UIAlertController(title: "Last order still in progress", message: "A new order cannot be accepted before your last order is fulfilled. Would you like to see the last order?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
          self.performSegue(withIdentifier: "PaymentView2DeliveryView", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true)

        return
      }

      let cardParams = self.cardTextField.cardParams
      let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
      let paymentIntentParams = STPPaymentIntentParams(clientSecret: self.paymentIntentSecret!)
      paymentIntentParams.paymentMethodParams = paymentMethodParams

      STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { status, intent, error in

        switch status {
        case .succeeded:
          APIClient.shared.createOrder { json in
            guard json != nil else {
              let alertController = UIAlertController(title: "Order processing failed", message: "Payment will be refunded within the next few days", preferredStyle: .alert)
              let action = UIAlertAction(title: "OK", style: .cancel)
              alertController.addAction(action)
              self.present(alertController, animated: true)
              return
            }

            Cart.current.reset()
            self.performSegue(withIdentifier: "PaymentView2DeliveryView", sender: self)
          }
        case .canceled:
          let alertController = UIAlertController(title: "Payment processing canceled", message: (error?.localizedDescription ?? ""), preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .cancel)
          alertController.addAction(action)
          self.present(alertController, animated: true)
        case .failed:
          let alertController = UIAlertController(title: "Payment processing failed", message: (error?.localizedDescription ?? ""), preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .cancel)
          alertController.addAction(action)
          self.present(alertController, animated: true)
        }
      }
    }
  }
}

extension PaymentViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}
