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
    }
    
    func configure(_ time: String, _ desc: String, _ name: String,_ isSeenNoti: Bool) {
        timeCreateOrderLabel.text = time
        descOrderLabel.text = desc
        nameOrderLabel.text = "Mã đơn hàng: \(name)"
        
        if isSeenNoti {
            containerView.backgroundColor = .clear
            containerView.layer.shadowColor = UIColor.clear.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
            containerView.layer.shadowRadius = 0
            containerView.layer.shadowOpacity = 0
            containerView.layer.masksToBounds = false
        } else {
            containerView.backgroundColor = .white
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 4.0
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.masksToBounds = false
        }
    }
}
