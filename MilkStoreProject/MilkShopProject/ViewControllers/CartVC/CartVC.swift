//
//  CartVC.swift
//  MilkShopProject
//
//  Created by CongDev on 9/4/25.
//

import UIKit
import Lottie
import FirebaseAuth

class CartVC: BaseViewController {
    
    @IBOutlet weak var selectedAllButton: UIButton!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var containerLoadingView: UIView!
    @IBOutlet weak var productEmptyView: UIView!
    @IBOutlet weak var totalPriceProductLabel: UILabel!
    @IBOutlet weak var productsInCartTableView: UITableView!
    
    private var cartItems: [CartModel] = []
    private var totalPrice = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpTableView(productsInCartTableView, ProductsCartCell.self)
        configureAnimation(loadingAnimationView, "loadingCart", isPlay: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDataCart()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.back()
    }
    
    private func fetchDataCart() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        containerLoadingView.isHidden = false
        productsInCartTableView.isHidden = true
        productEmptyView.isHidden = true
        cartItems.removeAll()
        
        CartService.shared.fetchCartItems(for: userId) { documents, error in
            if let error = error {
                print("Lỗi khi fetch cart: \(error.localizedDescription)")
                self.updateUIAfterFetch()
                return
            }
            
            guard let cartDocs = documents, !cartDocs.isEmpty else {
                self.updateUIAfterFetch()
                return
            }
            
            let group = DispatchGroup()
            
            for cartDoc in cartDocs {
                let productId = cartDoc["idproduct"] as? String ?? ""
                let quantity = cartDoc["quantity"] as? Int ?? 0
                
                group.enter()
                FirebaseDataFetcher.shared.fetchProduct(by: productId) { dataMilk in
                    defer { group.leave() }
                    
                    guard let dataMilk = dataMilk,
                          let nameMilk = dataMilk.nameMilk,
                          let imageProduct = dataMilk.imgMilk,
                          let price = dataMilk.price
                    else { return }
                    
                    let cartModel = CartModel(idProduct: productId,
                                              idUser: userId,
                                              nameProduct: nameMilk,
                                              imageProduct: imageProduct,
                                              price: price,
                                              quantity: quantity)
                    self.cartItems.append(cartModel)
                    self.productsInCartTableView.reloadData()
                }
            }
            
            group.notify(queue: .main) {
                self.updateUIAfterFetch()
                self.updateTotalPrice()
            }
        }
    }
    
    @IBAction func didTapSelectedAllButton(_ sender: Any) {
        let allSelected = cartItems.allSatisfy { $0.isSelected }
        
        cartItems = cartItems.map { item in
            var newItem = item
            newItem.isSelected = !allSelected
            return newItem
        }
            
        productsInCartTableView.reloadData()
        updateTotalPrice()
        updateSelectedAllButton()
    }
    
    @IBAction func didTapPurchaseButton(_ sender: Any) {
        guard cartItems.filter({ $0.isSelected }).isEmpty == false else {
            showAlert(title: "Error", message: "Bạn vẫn chưa chọn sản phẩm nào để mua.")
            return
        }
        
        let vc = OrderVC()
        vc.selectedCartItems = cartItems.filter { $0.isSelected }
        self.push(vc)
    }
    
    private func updateSelectedAllButton() {
        let allSelected = cartItems.allSatisfy { $0.isSelected }
        let imageSelected = UIImage(named: allSelected ? "ic_Tick" : "ic_Untick")?.withTintColor(.white)
        self.selectedAllButton.setImage(imageSelected, for: .normal)
    }
    
    private func updateUIAfterFetch() {
        DispatchQueue.main.async {
            self.containerLoadingView.isHidden = true
            let hasItems = !self.cartItems.isEmpty
            self.productEmptyView.isHidden = hasItems
            self.productsInCartTableView.isHidden = !hasItems
            self.productsInCartTableView.reloadData()
        }
    }
    
    private func updateTotalPrice() {
        let selectedItem = cartItems.filter { $0.isSelected }
        
        let totalPrice = selectedItem.reduce(0) { result, item in
            let price = self.convertPriceToInt(item.price)
            return result + ((price?.double ?? 0.0) * Double(item.quantity))
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        
        if let formattedString = formatter.string(from: NSNumber(value: totalPrice)) {
            totalPriceProductLabel.text = "\(formattedString) đ"
        } else {
            totalPriceProductLabel.text = "0 đ"
        }
    }
}

extension CartVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ProductsCartCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.configCell(items: cartItems[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CartVC: ProductCartCellDelegate {
    func didTapDeleteProduct(indexPath: IndexPath) {
        let items = cartItems[indexPath.row]
        
        CartService.shared.deleteCartItem(for: items.idUser, productId: items.idProduct) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.cartItems.remove(at: indexPath.row)
            self.productsInCartTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTotalPrice()
        }
    }
    
    func didTapMinusProduct(indexPath: IndexPath) {
        var item = cartItems[indexPath.row]
        guard item.quantity > 1 else { return }
        item.quantity -= 1
        cartItems[indexPath.row] = item
        
        CartService.shared.updateCartItem(for: item.idUser, productId: item.idProduct, quantity: item.quantity) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.productsInCartTableView.reloadRows(at: [indexPath], with: .none)
                self.updateTotalPrice()
            }
        }
    }
    
    func didTapPlusProduct(indexPath: IndexPath) {
        var item = cartItems[indexPath.row]
        item.quantity += 1
        cartItems[indexPath.row] = item
        
        CartService.shared.updateCartItem(for: item.idUser, productId: item.idProduct, quantity: item.quantity) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.productsInCartTableView.reloadRows(at: [indexPath], with: .none)
                self.updateTotalPrice()
            }
        }
    }
    
    func didTapChangeQuantity(indexPath: IndexPath, newQuantity: Int) {
        var item = cartItems[indexPath.row]
        item.quantity = newQuantity
        cartItems[indexPath.row] = item
        
        CartService.shared.updateCartItem(for: item.idUser, productId: item.idProduct, quantity: item.quantity) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.productsInCartTableView.reloadRows(at: [indexPath], with: .none)
                self.updateTotalPrice()
            }
        }
    }
    
    func didTapSelectedProduct(indexPath: IndexPath) {
        cartItems[indexPath.row].isSelected.toggle()
        self.productsInCartTableView.reloadRows(at: [indexPath], with: .none)
        self.updateTotalPrice()
        self.updateSelectedAllButton()
    }
}
