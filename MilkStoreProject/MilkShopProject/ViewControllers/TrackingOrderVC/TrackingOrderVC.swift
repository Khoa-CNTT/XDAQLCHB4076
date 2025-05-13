//
//  TrackingOrderVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit
import FirebaseAuth
import Kingfisher

class TrackingOrderVC: BaseViewController {
    
    @IBOutlet weak var trackingOrderTbView: UITableView!
    
    var orderData: [[String: Any]] = []
    var statusOrder: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(trackingOrderTbView, TrackingOrderCell.self)
        fetchOrderData()
    }
    
    func fetchOrderData() {
        if UDHelper.roleUser {
            FirebaseDataFetcher.shared.fetchAllOrders { [weak self] orders, error in
                if let error = error {
                    print("Error fetching all orders: \(error.localizedDescription)")
                    return
                }
                
                if let orders = orders {
                    self?.orderData = orders.filter { order in
                        return order["statusorder"] as? String == self?.statusOrder
                    }
                    DispatchQueue.main.async {
                        self?.trackingOrderTbView.reloadData()
                    }
                }
            }
        } else {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User ID not found")
                return
            }
            
            FirebaseDataFetcher.shared.fetchOrders(for: userId) { [weak self] orders, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }
                
                if let orders = orders {
                    self?.orderData = orders.filter { order in
                        return order["statusorder"] as? String == self?.statusOrder
                    }
                    DispatchQueue.main.async {
                        self?.trackingOrderTbView.reloadData()
                    }
                }
            }
        }
        
    }
}

extension TrackingOrderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TrackingOrderCell.self, for: indexPath)
        
        let order = orderData[indexPath.row]
        if let details = order["detail"] as? [[String: Any]], let quantity = details.first?["quantity"] as? Int {
            cell.quantityLabel.text = "Số lượng: \(quantity)"
        }
        
        if let statusOrder = order["statusorder"] as? String {
            cell.statusOrderLabel.text = "\(statusOrder)"
        }
        
        if let imgLink = order["detail"] as? [[String: Any]], let imageUrlString = imgLink.first?["pic"] as? String {
            if let url = URL(string: imageUrlString) {
                cell.productOrderImgView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            }
        }
        
        if let details = order["detail"] as? [[String: Any]], let name = details.first?["name"] as? String {
            cell.nameProductLabel.text = name
        }
        
        if let details = order["detail"] as? [[String: Any]], let price = details.first?["price"] as? String {
            cell.priceProductLabel.text = "Giá bán: \(price) đ"
        }
        
        if let totalPrice = order["totalprice"] as? Double, let details = order["detail"] as? [[String: Any]] {
            cell.totalPriceLabel.text = "Tổng số tiền (\(details.count) sản phẩm): \(formatCurrency(totalPrice)) đ"
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOrder = orderData[indexPath.row]
        let vc = DetailOrderVC()
        
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
                      let image = detailDict["pic"] as? String else {
                    return nil
                }
                return DetailOrderModel(name: name, price: price, quantity: quantity, image: image)
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
