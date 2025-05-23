//
//  InvoiceVC.swift
//  MilkShopProject
//
//  Created by CongDev on 13/5/25.
//

import UIKit

class InvoiceVC: BaseViewController {

    @IBOutlet weak var invoiceTableView: UITableView!
    
    var orders: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(invoiceTableView, InvoiceCell.self)
        fetchDataOrder()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
    
    private func fetchDataOrder() {
        FirebaseDataFetcher.shared.fetchAllOrders { [weak self] orders, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let orders = orders {
                self.orders = orders
            }
            self.invoiceTableView.reloadData()
            
        }
    }
}

extension InvoiceVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: InvoiceCell.self, for: indexPath)
        let order = orders[indexPath.row]
        
        if let status = order["statusorder"] as? String,
           let dateCreate = order["date"] as? String {
            
            cell.configure(dateCreate, status: status)
        }
        
        if let totalPrice = order["totalprice"] as? Double {
            cell.totalInvoiceLabel.text = "\(formatCurrency(totalPrice)) đ"
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOrder = orders[indexPath.row]
        let vc = DetailOrderVC(idOrder: "")
        
        if let statusOrder = selectedOrder["statusorder"] as? String,
           let totalPrice = selectedOrder["totalprice"] as? Int,
           let details = selectedOrder["detail"] as? [[String: Any]],
           let address = selectedOrder["address"] as? String,
           let date = selectedOrder["date"] as? String,
           let idPay = selectedOrder["idpay"] as? String,
           let idUser = selectedOrder["iduser"] as? String,
           let priceShip = selectedOrder["priceship"] as? String {
            
            let detailModels = details.compactMap { detailDict -> DetailOrderModel? in
                guard let name = detailDict["name"] as? String,
                      let price = detailDict["price"] as? String,
                      let quantity = detailDict["quantity"] as? Int,
                      let image = detailDict["pic"] as? String,
                      let idProduct = detailDict["idProduct"]  as? String else {
                    return nil
                }
                return DetailOrderModel(idProduct: idProduct, name: name, price: price, quantity: quantity, image: image)
            }
            
            let order = OrderModel(
                address: address,
                date: date,
                detail: detailModels,
                idPayment: idPay,
                idUser: idUser,
                priceShipping: priceShip,
                statusOrder: statusOrder,
                totalPrice: totalPrice)
            
            vc.order = order
            
            self.push(vc)
        }
    }
}
