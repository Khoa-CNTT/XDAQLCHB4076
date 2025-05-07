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
        let url = URL(string: order.imageProduct)
        self.productOrderImgView.kf.indicatorType = .activity
        self.productOrderImgView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.3))
            ]
        )
    }
}
