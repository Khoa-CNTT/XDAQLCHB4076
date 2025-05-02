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
        let url = URL(string: products.imgMilk)
        self.productImageView.kf.indicatorType = .activity
        self.productImageView.kf.setImage(
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
    }
}
