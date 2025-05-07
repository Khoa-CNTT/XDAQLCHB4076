//
//  OrderVC.swift
//  MilkShopProject
//
//  Created by CongDev on 5/5/25.
//

import UIKit

class OrderVC: BaseViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ctnHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    
    var selectedCartItems: [CartModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView(orderTableView, OrderCell.self)
        orderTableView.reloadData()
        updatePriceLabels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.ctnHeightTableView.constant = self.orderTableView.contentSize.height
        self.view.layoutIfNeeded()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
    
    @IBAction func didTapAddressButton(_ sender: UIButton) {
        let vc = AddressVC()
        vc.delegate = self
        self.push(vc)
    }
    
    @IBAction func didTapPaymentButton(_ sender: Any) {
        
    }
    
    private func updatePriceLabels() {
        let totalCost = selectedCartItems.reduce(0.0) { result, item in
            result + (Double(item.quantity) * (Double(convertPriceToInt(item.price) ?? 0)))
        }
        let shipping: Double = 15000

        totalCostLabel.text = "\(formatCurrency(totalCost)) đ"
        shippingLabel.text = "\(formatCurrency(shipping)) đ"
        totalPaymentLabel.text = "\(formatCurrency(totalCost + shipping)) đ"
        totalLabel.text = "\(formatCurrency(totalCost + shipping)) đ"
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

extension OrderVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: OrderCell.self, for: indexPath)
        cell.configure(with: selectedCartItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension OrderVC: AddressVCDelegate {
    func callBackAddress(address: String) {
        self.addressLabel.text = address
    }
}
