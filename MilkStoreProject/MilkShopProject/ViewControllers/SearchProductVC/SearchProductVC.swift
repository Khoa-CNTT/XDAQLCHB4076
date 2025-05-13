//
//  SearchProductVC.swift
//  MilkShopProject
//
//  Created by CongDev on 12/5/25.
//

import UIKit

class SearchProductVC: BaseViewController {

    @IBOutlet weak var emptyProductLabel: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchTableView: UITableView!

    var products: [DataMilkObject] = []
    var filteredProducts: [DataMilkObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(searchTableView, SearchTableCell.self)
        self.products = RealmManager.shared.getAll(for: DataMilkObject.self)
        self.filteredProducts = products
        self.searchTableView.reloadData()
        
        self.searchTF.keyboardType = .default
        self.searchTF.returnKeyType = .search
        self.searchTF.delegate = self
        
        self.emptyProductLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchTF.becomeFirstResponder()
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        self.dismiss()
    }
    
    func updateUIForSearchResults() {
        if filteredProducts.isEmpty {
            self.emptyProductLabel.isHidden = false
            self.searchTableView.isHidden = true
        } else {
            self.emptyProductLabel.isHidden = true
            self.searchTableView.isHidden = false
        }
    }
}

extension SearchProductVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchText = textField.text?.lowercased() ?? ""
        
        filteredProducts = products.filter { product in
            return product.nameMilk?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).contains(searchText) ?? false
        }

        filteredProducts = Array(Set(filteredProducts))
        print(filteredProducts.count)
        updateUIForSearchResults()
        self.searchTableView.reloadData()
        textField.resignFirstResponder()
        
        return true
    }
}

extension SearchProductVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SearchTableCell.self, for: indexPath)
        cell.nameProductLabel.text = filteredProducts[indexPath.row].nameMilk
        let url = URL(string: filteredProducts[indexPath.row].imgMilk)
        cell.productImageView.kf.indicatorType = .activity
        cell.productImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.3))
            ],
            completionHandler: { result in
                switch result {
                case .success(let value):
                    print("Image loaded: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        )
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailProductsVC(dataMilk: filteredProducts[indexPath.row])
        push(vc)
    }
}
