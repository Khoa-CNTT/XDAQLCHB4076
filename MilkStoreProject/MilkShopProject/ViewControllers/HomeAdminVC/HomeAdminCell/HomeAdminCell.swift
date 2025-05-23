//
//  HomeAdminCell.swift
//  MilkShopProject
//
//  Created by CongDev on 23/5/25.
//

import UIKit

class HomeAdminCell: UITableViewCell {

    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var nameProductLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadow(alpha: 0.5, isTop: false, color: .black.withAlphaComponent(0.5))
    }
    
    func configure(item: DataMilkObject) {
        if let sell = item.sell,
           let revenue = item.totalSell {
            self.sellLabel.text = "Đã bán: \(sell)"
            self.revenueLabel.text = "Doanh thu: \(revenue)"
            self.nameProductLabel.text = item.nameMilk
        }
    }
}
