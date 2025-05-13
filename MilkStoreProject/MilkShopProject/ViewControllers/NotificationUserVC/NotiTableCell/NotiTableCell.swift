//
//  NotiTableCell.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

class NotiTableCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeCreateOrderLabel: UILabel!
    @IBOutlet weak var descOrderLabel: UILabel!
    @IBOutlet weak var nameOrderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
    }
}
