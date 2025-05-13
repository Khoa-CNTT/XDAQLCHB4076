//
//  InfoCell.swift
//  MilkShopProject
//
//  Created by CongDev on 9/5/25.
//

import UIKit

class InfoCell: UITableViewCell {

    @IBOutlet weak var nameInfoLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(image: UIImage, name: String) {
        self.infoImageView.image = image
        self.nameInfoLabel.text = name
    }
}
