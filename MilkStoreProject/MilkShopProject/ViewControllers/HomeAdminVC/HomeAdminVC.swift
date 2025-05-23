//
//  HomeAdminVC.swift
//  MilkShopProject
//
//  Created by CongDev on 22/5/25.
//

import UIKit
import DGCharts

class HomeAdminVC: BaseViewController {
    
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var barChartView: BarChartView!
    
    private var milks: [DataMilkObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.milks = RealmManager.shared.getAll(for: DataMilkObject.self)
                .sorted(by: { ($0.totalSell ?? 0) > ($1.totalSell ?? 0) })
        
        fetchAndShowRevenueChart()
        setUpTableView(productTableView, HomeAdminCell.self)
        self.productTableView.reloadData()
    }

    private func fetchAndShowRevenueChart() {
        FirebaseDataFetcher.shared.fetchAllOrders { orders, error in
            guard let orders = orders, error == nil else {
                print("Lỗi fetch orders: \(error?.localizedDescription)")
                return
            }
            let grouped = Dictionary(grouping: orders, by: {
                let fullDate = $0["date"] as? String ?? ""
                return fullDate.components(separatedBy: " ").first ?? fullDate
            })
            let chartData: [(date: String, total: Double)] = grouped.map { (date, orders) in
                let total = orders.reduce(0) { $0 + (Double($1["totalprice"] as? Int ?? 0)) }
                return (date: date, total: total)
            }.filter { !$0.date.isEmpty }.sorted { $0.date < $1.date }

            let entries = chartData.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.total) }
            let xAxisLabels = chartData.map { $0.date }


            let dataSet = BarChartDataSet(entries: entries, label: "Tổng doanh thu")
            dataSet.colors = [UIColor.systemYellow]
            let data = BarChartData(dataSet: dataSet)
            data.setDrawValues(true)
            data.barWidth = 0.3
            self.barChartView.data = data

            self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
            self.barChartView.xAxis.granularity = 1
            self.barChartView.xAxis.labelPosition = .bottom
            self.barChartView.xAxis.drawGridLinesEnabled = false
            self.barChartView.xAxis.labelRotationAngle = -25
            self.barChartView.xAxis.labelFont = .systemFont(ofSize: 10)
            self.barChartView.setVisibleXRangeMaximum(5)
            self.barChartView.moveViewToX(0)
            self.barChartView.leftAxis.axisMinimum = 0
            self.barChartView.rightAxis.enabled = false
            self.barChartView.legend.enabled = true
            self.barChartView.chartDescription.enabled = false
            
            self.barChartView.notifyDataSetChanged()
        }
    }
}

extension HomeAdminVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return milks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HomeAdminCell.self, for: indexPath)
        cell.configure(item: milks[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailProductsVC(dataMilk: milks[indexPath.row])
        self.push(vc)
    }
}
