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

    func configCell(products: DataMilkObject) {
        self.nameProductLabel.text = products.nameMilk
        self.priceProductLabel.text = products.price
        if let imageUrl = products.imgMilk {
            productImageView.loadImage(from: imageUrl)
        }
    }
}
