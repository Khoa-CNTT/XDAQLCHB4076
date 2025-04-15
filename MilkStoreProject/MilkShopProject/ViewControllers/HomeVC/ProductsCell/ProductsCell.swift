//
//  ProductsCell.swift
//  MilkShopProject
//
//  Created by CongDev on 7/4/25.
//

import UIKit
import Kingfisher

class ProductsCell: UICollectionViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var priceProductLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configCell(products: DataMilk) {
        self.nameProductLabel.text = products.nameMilk
        self.priceProductLabel.text = products.price
        if let url = URL(string: products.imgMilk) {
            self.productImageView.kf.setImage(with: url)
        }
    }
}
