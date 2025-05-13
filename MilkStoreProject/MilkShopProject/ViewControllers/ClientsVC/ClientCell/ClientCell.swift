//
//  ClientCell.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class ClientCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
    }
    
    func configure(_ name: String,_ phone: String) {
        self.nameUserLabel.text = name
        self.phoneNumberLabel.text = phone
    }
}
