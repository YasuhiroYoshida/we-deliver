//
//  EarningsViewController.swift
//  WeDeliver
//
//  Created by Yasuhiro Yoshida on 2021-12-13.
//

import UIKit
import Charts

class EarningsViewController: UIViewController {
  // MARK: - Vars
//  let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  var earnings: [BarChartDataEntry]!

  // MARK: - IBOutlets
  @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var earningsBarChartView: BarChartView!

  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()

    if revealViewController() != nil {
      menuBarButtonItem.target = revealViewController()
      menuBarButtonItem.action = #selector(revealViewController().revealToggle(_:))
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    initCharts()
    loadEarnings()
  }

  func initCharts() {
    earningsBarChartView.legend.enabled = false
    earningsBarChartView.xAxis.labelPosition = .bottom
    earningsBarChartView.xAxis.drawGridLinesEnabled = false
    earningsBarChartView.leftAxis.axisMinimum = 0
    earningsBarChartView.scaleXEnabled = false
    earningsBarChartView.scaleYEnabled = false
    earningsBarChartView.rightAxis.enabled = false
    earningsBarChartView.pinchZoomEnabled = false
    earningsBarChartView.doubleTapToZoomEnabled = false
    earningsBarChartView.animate(yAxisDuration: 2.0, easingOption: .easeInBounce)
    earningsBarChartView.noDataText = "No Data Available"
  }

  func loadEarnings() {
    APIClient.shared.earnings { json in
      if let revenues = json?["daily_revenue_this_week"] {
        let xAxisLabels = Array(revenues.dictionary!.keys)
        self.earningsBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)

        let dataEntries = revenues.enumerated().map { BarChartDataEntry(x: Double($0), y: $1.1.double ?? 0.0) }
        let dataset = BarChartDataSet(dataEntries)
        dataset.colors = ChartColorTemplates.material()
        let data = BarChartData(dataSet: dataset)
        self.earningsBarChartView.data = data
      }
    }
  }
}
