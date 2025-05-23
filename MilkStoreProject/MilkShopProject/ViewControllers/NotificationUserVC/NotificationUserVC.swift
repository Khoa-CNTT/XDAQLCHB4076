//
//  NotificationUserVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class NotificationUserVC: BaseViewController {

    @IBOutlet weak var notificationTbView: UITableView!
    
    private var notifications: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpTableView(notificationTbView, NotiTableCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchNotification()
    }
    
    private func fetchNotification() {
        self.showHUD()
        if UDHelper.roleUser {
            FirebaseDataFetcher.shared.fetchAllNotifications { [weak self] noti, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }
                self.dismissHUD()
                if let noti = noti {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                    self.notifications = noti.sorted {
                        guard
                            let date1Str = $0["datetime"] as? String,
                            let date2Str = $1["datetime"] as? String,
                            let date1 = dateFormatter.date(from: date1Str),
                            let date2 = dateFormatter.date(from: date2Str)
                        else { return false }
                        return date1 > date2
                    }
                }
                self.notificationTbView.reloadData()
            }
        } else {
            FirebaseDataFetcher.shared.fetchNotifications { [weak self] noti, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }
                self.dismissHUD()
                if let noti = noti {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                    self.notifications = noti.sorted {
                        guard
                            let date1Str = $0["datetime"] as? String,
                            let date2Str = $1["datetime"] as? String,
                            let date1 = dateFormatter.date(from: date1Str),
                            let date2 = dateFormatter.date(from: date2Str)
                        else { return false }
                        return date1 > date2
                    }
                }
                self.notificationTbView.reloadData()
            }
        }
    }
}

extension NotificationUserVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: NotiTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        let noti = notifications[indexPath.row]
        cell.configure(
            noti["datetime"] as! String,
            noti["notification"] as! String,
            noti["idorder"] as! String,
            noti["isSeen"] as! Bool
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNoti = notifications[indexPath.row]
        
        if let notificationId = selectedNoti["documentID"] as? String {
            FirebaseDataFetcher.shared.updateNotificationSeenStatus(notificationId: notificationId) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Error updating notification status: \(error.localizedDescription)")
                } else {
                    self.notifications[indexPath.row]["isSeen"] = true
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
        
        if let idOrder = selectedNoti["idorder"] as? String {
            FirebaseDataFetcher.shared.fetchOrderById(idOrder: idOrder) { [weak self] orderData, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching order: \(error.localizedDescription)")
                    return
                }
                
                guard let orderData = orderData,
                      let statusOrder = orderData["statusorder"] as? String,
                      let totalPrice = orderData["totalprice"] as? Int,
                      let details = orderData["detail"] as? [[String: Any]],
                      let address = orderData["address"] as? String,
                      let date = orderData["date"] as? String,
                      let idPay = orderData["idpay"] as? String,
                      let idUser = orderData["iduser"] as? String,
                      let priceShip = orderData["priceship"] as? String else {
                    print("Invalid order data")
                    return
                }
                
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
                
                DispatchQueue.main.async {
                    let vc = DetailOrderVC(idOrder: selectedNoti["idorder"] as? String ?? "")
                    vc.order = order
                    self.push(vc)
                }
            }
        }
    }
}
