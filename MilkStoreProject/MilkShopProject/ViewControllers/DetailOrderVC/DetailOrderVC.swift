//
//  DetailOrderVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit
import FirebaseFirestore

class DetailOrderVC: BaseViewController {
    
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusOrderLabel: UILabel!
    @IBOutlet weak var detailOrderTableView: UITableView!
    @IBOutlet weak var ctnHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    var order: OrderModel?
    private var idOrder: String
    
    init(idOrder: String) {
        self.idOrder = idOrder
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        self.idOrder = ""
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(detailOrderTableView, OrderCell.self)
        
        // Thêm log để kiểm tra dữ liệu
        print("DetailOrderVC - Order ID: \(idOrder)")
        print("DetailOrderVC - Order Data: \(String(describing: order))")
        
        if UDHelper.roleUser {
            self.completedButton.isHidden = false
            self.completedButton.setTitle("HOÀN THÀNH", for: .normal)
        } else {
            if order?.statusOrder == Global.orderConfirm {
                self.completedButton.isHidden = false
                self.completedButton.setTitle("HUỶ", for: .normal)
            } else {
                self.completedButton.isHidden = true
            }
        }
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
    
    @IBAction func didTapCompletedButton(_ sender: Any) {
        guard let order = order else { return }
        guard !idOrder.isEmpty else {
            showAlert(title: "Lỗi", message: "Không tìm thấy thông tin đơn hàng")
            return
        }
        
        if UDHelper.roleUser {
            let newStatus: String
            switch order.statusOrder {
            case Global.orderConfirm:
                newStatus = Global.orderWaitShip
            case Global.orderWaitShip:
                newStatus = Global.orderShipped
            case Global.orderShipped:
                newStatus = Global.orderCompleted
            default:
                return
            }
            
            let db = Firestore.firestore()
            let orderRef = db.collection("order").document(idOrder)
            
            orderRef.updateData([
                "statusorder": newStatus
            ]) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error updating order status: \(error.localizedDescription)")
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                let formattedDate = dateFormatter.string(from: Date())
                
                let notificationRef = db.collection("notification").document()
                
                notificationRef.setData([
                    "datetime": formattedDate,
                    "idorder": self.idOrder,
                    "isSeen": false,
                    "name": order.idUser,
                    "notification": "Đơn hàng của bạn đã được cập nhật: \(newStatus)",
                    "role": false
                ]) { error in
                    if let error = error {
                        print("Error creating notification: \(error.localizedDescription)")
                    } else {
                        print("Notification created successfully!")
                        
                        DispatchQueue.main.async {
                            self.order?.statusOrder = newStatus
                            self.statusOrderLabel.text = newStatus
                            
                            if newStatus == Global.orderCompleted {
                                self.completedButton.isHidden = true
                            }
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        } else {
            // Xử lý cho user hủy đơn hàng
            
            print("Refund - Transaction ID: \(order.idPayment)")
            
            let db = Firestore.firestore()
            let orderRef = db.collection("order").document(idOrder)
            
            // Tính toán số tiền cần refund
            let totalCost = order.detail.reduce(0.0) { result, item in
                result + (Double(item.quantity) * (Double(convertPriceToInt(item.price) ?? 0)))
            }
            let totalRefund = Int(totalCost + Double(convertPriceToInt(order.priceShipping) ?? 0))
            
            //Thực hiện refund qua ZaloPay
            ZaloPayService.shared.refundOrder(zpTransId: order.idPayment, amount: totalRefund) { [weak self] success,message  in
                guard let self = self else { return }
                print("Refund completion: \(success)")
                if success {
                    // Cập nhật trạng thái đơn hàng
                    orderRef.updateData([
                        "statusorder": Global.orderCancel
                    ]) { error in
                        if let error = error {
                            print("Error canceling order: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.showAlert(title: "Lỗi", message: "Không thể cập nhật trạng thái đơn hàng: \(error.localizedDescription)")
                            }
                            return
                        }
                        // Tạo notification về việc hủy đơn hàng
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                        let formattedDate = dateFormatter.string(from: Date())
                        let notificationRef = db.collection("notification").document()
                        notificationRef.setData([
                            "datetime": formattedDate,
                            "idorder": self.idOrder,
                            "isSeen": false,
                            "name": order.idUser,
                            "notification": "Đơn hàng đã bị hủy bởi người dùng. Số tiền \(self.formatCurrency(Double(totalRefund))) đã được hoàn trả.",
                            "role": true
                        ]) { error in
                            if let error = error {
                                print("Error creating notification: \(error.localizedDescription)")
                            } else {
                                print("Notification created successfully!")
                                DispatchQueue.main.async {
                                    self.order?.statusOrder = Global.orderCancel
                                    self.statusOrderLabel.text = Global.orderCancel
                                    self.completedButton.isHidden = true
                                    self.showAlert(title: "Thành công", message: "Đơn hàng đã được hủy. Số tiền \(self.formatCurrency(Double(totalRefund))) đã được hoàn trả về tài khoản của bạn.") { _ in
                                        AppDelegate.setRoot(TabbarCustomController(), isNavi: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Lỗi", message: message) { _ in
                            AppDelegate.setRoot(TabbarCustomController(), isNavi: true)
                        }
                    }
                }
            }
        }
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
