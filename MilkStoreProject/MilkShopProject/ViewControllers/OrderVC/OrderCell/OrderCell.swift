//
//  OrderCell.swift
//  MilkShopProject
//
//  Created by CongDev on 5/5/25.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceProductLabel: UILabel!
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var productOrderImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with order: CartModel) {
        self.quantityLabel.text = "x\(order.quantity)"
        self.priceProductLabel.text = order.price
        self.nameProductLabel.text = order.nameProduct
        let url = order.imageProduct
        self.productOrderImgView.loadImage(from: url)
    }
    
    func configureDetailOrder(with order: DetailOrderModel) {
        self.quantityLabel.text = "x\(order.quantity)"
        self.priceProductLabel.text = order.price
        self.nameProductLabel.text = order.name
        let url = order.image
        self.productOrderImgView.loadImage(from: url)
    }
}
