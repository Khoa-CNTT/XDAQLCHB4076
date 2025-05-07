//
//  ProvinceCell.swift
//  MilkShopProject
//
//  Created by CongDev on 6/5/25.
//

import UIKit

class ProvinceCell: UITableViewCell {

    @IBOutlet weak var nameProvinceLabel: UILabel!
    @IBOutlet weak var selectedProvinceLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(name: String, isSelected: Bool) {
        self.nameProvinceLabel.text = name
        self.selectedProvinceLabel.image = isSelected ? UIImage(named: "ic_Tick") : UIImage(named: "ic_Untick")
    }
}
