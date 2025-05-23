//
//  ProductCell.swift
//  MilkShopProject
//
//  Created by CongDev on 13/5/25.
//

import UIKit

protocol ProductCellDelegate: AnyObject {
    func didTapSelectProductButton(indexPath: IndexPath)
}

class ProductCell: UITableViewCell {

    @IBOutlet weak var containerQuantityView: UIView!
    @IBOutlet weak var containerSellView: UIView!
    @IBOutlet weak var selectdProductButton: UIButton!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var quantityProductLabel: UILabel!
    
    var indexPath: IndexPath?
    weak var delegate: ProductCellDelegate?
    var isSelectedProduct: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadow(alpha: 0.5, isTop: false, color: .black.withAlphaComponent(0.5))
        setupSelectedButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectdProductButton.setImage(UIImage(named: "ic_Untick")?.withTintColor(.black), for: .normal)
    }
    
    private func setupSelectedButton() {
        selectdProductButton.setImage(UIImage(named: "ic_Untick")?.withTintColor(.black), for: .normal)
        selectdProductButton.setImage(UIImage(named: "ic_Tick")?.withTintColor(.black), for: .selected)
    }
    
    @IBAction func didTapSelectedProductButton(_ sender: Any) {
        isSelectedProduct.toggle()
        selectdProductButton.isSelected = isSelectedProduct
        if let indexPath = indexPath {
            delegate?.didTapSelectProductButton(indexPath: indexPath)
        }
    }
    
    func configure(_ product: DataMilkObject, indexPath: IndexPath) {
        if let imageUrl = product.imgMilk {
            productImageView.loadImage(from: imageUrl)
        }
        self.productNameLabel.text = product.nameMilk
        self.productPriceLabel.text = product.price
        self.quantityProductLabel.text = "\(product.quantity ?? 0)"
        
        self.indexPath = indexPath
        self.addProductButton.isHidden = indexPath.row != 0
        self.productImageView.isHidden = indexPath.row == 0
        self.productNameLabel.isHidden = indexPath.row == 0
        self.containerQuantityView.isHidden = indexPath.row == 0
        self.selectdProductButton.isHidden = indexPath.row == 0
        self.containerSellView.isHidden = indexPath.row == 0
    }
}
