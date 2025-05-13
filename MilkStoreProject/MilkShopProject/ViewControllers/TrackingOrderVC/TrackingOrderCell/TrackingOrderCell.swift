//
//  TrackingOrderCell.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class TrackingOrderCell: UITableViewCell {

    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceProductLabel: UILabel!
    @IBOutlet weak var productOrderImgView: UIImageView!
    
    @IBOutlet weak var statusOrderLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
