//
//  DetailOrderVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class DetailOrderVC: BaseViewController {

    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusOrderLabel: UILabel!
    @IBOutlet weak var detailOrderTableView: UITableView!
    @IBOutlet weak var ctnHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    var order: OrderModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView(detailOrderTableView, OrderCell.self)
    }
    
    override func setupUI() {
        guard let order = order else { return }
        
        let totalCost = order.detail.reduce(0.0) { result, item in
            result + (Double(item.quantity) * (Double(convertPriceToInt(item.price) ?? 0)))
        }
        
        self.addressLabel.text = order.address
        self.statusOrderLabel.text = order.statusOrder
        self.totalCostLabel.text = "\(formatCurrency(totalCost)) đ"
        self.shippingLabel.text = "\(order.priceShipping) đ"
        self.totalPaymentLabel.text = "\(formatCurrency(totalCost + Double(convertPriceToInt(order.priceShipping) ?? 0))) đ"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.ctnHeightTableView.constant = self.detailOrderTableView.contentSize.height
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.back()
    }
}

extension DetailOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let order = order else { return  0 }
        return order.detail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: OrderCell.self, for: indexPath)
        guard let order = order else { return  UITableViewCell() }
        cell.configureDetailOrder(with: order.detail[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
