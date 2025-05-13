//
//  ProductsVC.swift
//  MilkShopProject
//
//  Created by CongDev on 13/5/25.
//

import UIKit

class ProductsVC: BaseViewController {
    
    @IBOutlet weak var emptyProductLabel: UILabel!
    @IBOutlet weak var searchProductTF: UITextField!
    @IBOutlet weak var productTableView: UITableView!
    
    private var milks: [DataMilkObject] = []
    private var allMilks: [DataMilkObject] = []
    private var indexselectedProdut = 0
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allMilks = RealmManager.shared.getAll(for: DataMilkObject.self)
        self.milks = allMilks
        
        print("countproduct: \(allMilks.count), \(milks.count)")
        
        setUpTableView(productTableView, ProductCell.self)
        
        self.searchProductTF.keyboardType = .default
        self.searchProductTF.returnKeyType = .search
        self.searchProductTF.delegate = self
        
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let contentInsets = UIEdgeInsets(top: 16, left: 0, bottom: 70, right: 0)
        productTableView.contentInset = contentInsets
        productTableView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        showDeleteConfirmation()
    }
    
    @IBAction func deleteBackTapped(_ sender: UIButton) {
        self.back()
    }
}

extension ProductsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return milks.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ProductCell.self, for: indexPath)
        if indexPath.row == 0 {
            cell.configure(DataMilkObject(), indexPath: indexPath)
        } else {
            cell.configure(milks[indexPath.row - 1], indexPath: indexPath)
        }
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else {
            return 130
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("push to add new product")
        } else {
            let detailVC = DetailProductsVC(dataMilk: milks[indexPath.row - 1])
            self.push(detailVC)
        }
    }
}

extension ProductsVC: ProductCellDelegate {
    func didTapSelectProductButton(indexPath: IndexPath) {
        self.indexselectedProdut = indexPath.row - 1
        
    }
}

extension ProductsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        showLoadingAndSearch()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            milks = allMilks
            productTableView.isHidden = false
            emptyProductLabel.isHidden = true
            productTableView.reloadData()
        }
        return true
    }
}

extension ProductsVC {
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Xác nhận", message: "Bạn có muốn xóa không?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Có", style: .destructive) { _ in
            self.deleteProduct(at: self.indexselectedProdut)
        }
        
        let cancelAction = UIAlertAction(title: "Không", style: .cancel, handler: nil)
        
        if #available(iOS 15.0, *) {
            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoadingAndSearch() {
        loadingIndicator.startAnimating()
        emptyProductLabel.isHidden = true
        productTableView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            let searchText = self.searchProductTF.text?.lowercased() ?? ""
            let filtered = self.allMilks.filter { ($0.nameMilk?.lowercased().contains(searchText) ?? false) }
            self.loadingIndicator.stopAnimating()
            if filtered.isEmpty {
                emptyProductLabel.isHidden = false
                productTableView.isHidden = true
            } else {
                self.emptyProductLabel.isHidden = true
                self.productTableView.isHidden = false
                self.milks = filtered
                self.productTableView.reloadData()
            }
        }
    }
    
    private func deleteProduct(at index: Int) {
        let product = milks[index]
        let idProduct = product.idProduct
        RealmManager.shared.remove(product)
        if let idProduct = idProduct {
            FirebaseUploader.shared.deleteProductFromFirebase(idProduct: idProduct) { [weak self] error in
                guard let self = self else { return }
                self.allMilks = RealmManager.shared.getAll(for: DataMilkObject.self)
                self.milks = self.allMilks
                self.productTableView.reloadData()
                print("delete item:\(idProduct) at \(index)")
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}
