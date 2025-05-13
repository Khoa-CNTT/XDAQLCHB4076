//
//  OrderVC.swift
//  MilkShopProject
//
//  Created by CongDev on 5/5/25.
//

import UIKit
import zpdk
import Firebase

class OrderVC: BaseViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ctnHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    
    var selectedCartItems: [CartModel] = []
    private var totalAmount: Int = 0
    private let shipping: Double = Double(Int.random(in: 15...25) * 1000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(orderTableView, OrderCell.self)
        orderTableView.reloadData()
        updatePriceLabels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.ctnHeightTableView.constant = self.orderTableView.contentSize.height
        }
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
        if addressLabel.text == "Nhấn để chọn" {
            showToast(message: "Vui lòng chọn địa chỉ")
            return
        }
        
        let totalCost = selectedCartItems.reduce(0.0) { result, item in
            result + (Double(item.quantity) * (Double(convertPriceToInt(item.price) ?? 0)))
        }
        totalAmount = Int(totalCost + shipping)
        
        ZaloPayService.shared.createOrder(amount: totalAmount) { zpToken in
            DispatchQueue.main.async {
                guard let token = zpToken else {
                    self.showAlert(title: "Lỗi", message: "Không tạo được đơn hàng")
                    return
                }
                
                if UIApplication.shared.canOpenURL(URL(string: "zalopay://")!) {
                    ZaloPaySDK.sharedInstance()?.paymentDelegate = self
                    ZaloPaySDK.sharedInstance()?.payOrder(token)
                } else {
                    ZaloPayService.shared.installSandbox(from: self)
                }
            }
        }
    }
    
    private func updatePriceLabels() {
        let totalCost = selectedCartItems.reduce(0.0) { result, item in
            result + (Double(item.quantity) * (Double(convertPriceToInt(item.price) ?? 0)))
        }
        
        totalCostLabel.text = "\(formatCurrency(totalCost)) đ"
        shippingLabel.text = "\(formatCurrency(shipping)) đ"
        totalPaymentLabel.text = "\(formatCurrency(totalCost + shipping)) đ"
        totalLabel.text = "\(formatCurrency(totalCost + shipping)) đ"
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

extension OrderVC: ZPPaymentDelegate {
    func paymentDidSucceeded(_ transactionId: String!, zpTranstoken: String!, appTransId: String!) {
        self.showAlert(title: "Thành công", message: "Thanh toán thành công!")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print(NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy ID người dùng"]))
            return
        }
        
        let address = self.addressLabel.text ?? "Địa chỉ mặc định"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: Date())
        let detail = selectedCartItems.map { item in
            return [
                "price": formatCurrency((Double(convertPriceToInt(item.price) ?? 0))),
                "pic": item.imageProduct,
                "quantity": item.quantity,
                "name": item.nameProduct
            ]
        }
        let idpay = appTransId ?? ""
        let iduser = userId
        let priceship = formatCurrency(shipping)
        let statusorder = Global.orderConfirm
        let totalprice = totalAmount
        
        let db = Firestore.firestore()
        let orderRef = db.collection("order").document()
        
        orderRef.setData([
            "address": address,
            "date": formattedDate,
            "detail": detail,
            "idpay": idpay,
            "iduser": iduser,
            "priceship": priceship,
            "statusorder": statusorder,
            "totalprice": totalprice
        ]) { error in
            if let error = error {
                print("Error creating order in Firestore: \(error.localizedDescription)")
            } else {
                print("Order successfully created in Firestore!")
                
                let notificationRef = db.collection("notification").document()
                
                notificationRef.setData([
                    "datetime": formattedDate,
                    "idorder": orderRef.documentID,
                    "isSeen": false,
                    "name": userId,
                    "notification": "Bạn có đơn hàng mới",
                    "role": true
                ]) { error in
                    if let error = error {
                        print("Error creating notification: \(error.localizedDescription)")
                    } else {
                        print("Notification created successfully!")
                    }
                }
                
                for item in self.selectedCartItems {
                    FirebaseUploader.shared.updateProductAfterPurchase(productId: item.idProduct, quantityPurchased: item.quantity) { error in
                        if let error = error {
                            print("Error updating product after purchase: \(error.localizedDescription)")
                        } else {
                            print("Product updated successfully after purchase.")
                        }
                    }
                }
                
                CartService.shared.removeAllItemsInCart(for: userId) { error in
                    if let error = error {
                        print("Error clearing cart: \(error.localizedDescription)")
                    } else {
                        print("Cart cleared successfully")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            AppDelegate.setRoot(TabbarCustomController(), isNavi: true)
                        }
                    }
                }
            }
        }
    }
    
    func paymentDidCanceled(_ zpTranstoken: String!, appTransId: String!) {}
    
    func paymentDidError(_ errorCode: ZPPaymentErrorCode, zpTranstoken: String!, appTransId: String!) {
        self.showAlert(title: "Lỗi", message: "Thanh toán thất bại: \(errorCode.rawValue)")
    }
}
