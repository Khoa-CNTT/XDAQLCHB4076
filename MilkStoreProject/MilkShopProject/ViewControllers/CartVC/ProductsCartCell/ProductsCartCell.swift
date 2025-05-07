//
//  ProductsCartCell.swift
//  MilkShopProject
//
//  Created by CongDev on 29/4/25.
//

import UIKit
import Kingfisher

protocol ProductCartCellDelegate: AnyObject {
    func didTapDeleteProduct(indexPath: IndexPath)
    func didTapMinusProduct(indexPath: IndexPath)
    func didTapPlusProduct(indexPath: IndexPath)
    func didTapChangeQuantity(indexPath: IndexPath, newQuantity: Int)
    func didTapSelectedProduct(indexPath: IndexPath)
}

class ProductsCartCell: UITableViewCell {

    @IBOutlet weak var priceProductLabel: UILabel!
    @IBOutlet weak var countProductTF: UITextField!
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var productCartImageView: UIImageView!
    
    @IBOutlet weak var selectedProductButton: UIButton!
    weak var delegate: ProductCartCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countProductTF.keyboardType = .numberPad
        addDoneButtonOnKeyboard(textField: self.countProductTF)
    }
    
    @IBAction func didTapDeleteProductButton(_ sender: Any) {
        if let indexPath = self.indexPath {
            self.delegate?.didTapDeleteProduct(indexPath: indexPath)
        }
    }
    
    @IBAction func didTapMinusProductButton(_ sender: Any) {
        if let indexPath = self.indexPath {
            self.delegate?.didTapMinusProduct(indexPath: indexPath)
        }
    }
    
    @IBAction func didTapPlusProductButton(_ sender: Any) {
        if let indexPath = self.indexPath {
            self.delegate?.didTapPlusProduct(indexPath: indexPath)
        }
    }

    @IBAction func didTapSelectedProductButton(_ sender: Any) {
        if let indexPath = self.indexPath {
            self.delegate?.didTapSelectedProduct(indexPath: indexPath)
        }
    }
    
    func configCell(items: CartModel) {
        self.countProductTF.text = "\(items.quantity)"
        self.nameProductLabel.text = items.nameProduct
        self.priceProductLabel.text = "\(items.price)"
        let url = URL(string: items.imageProduct)
        self.productCartImageView.kf.indicatorType = .activity
        self.productCartImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.3))
            ]
        )
        
        let iconSelected = items.isSelected ? UIImage(named: "ic_Tick")?.withTintColor(.black) : UIImage(named: "ic_Untick")?.withTintColor(.black)
        self.selectedProductButton.setImage(iconSelected, for: .normal)
    }
    
    
    //MARK: Handle func
    func addDoneButtonOnKeyboard(textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        if let indexPath {
            self.delegate?.didTapChangeQuantity(indexPath: indexPath, newQuantity: Int(self.countProductTF.text ?? "") ?? 0)
        }
        countProductTF.resignFirstResponder()
    }
}
