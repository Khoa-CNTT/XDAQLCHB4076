//
//  InvoiceCell.swift
//  MilkShopProject
//
//  Created by CongDev on 13/5/25.
//

import UIKit

class InvoiceCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateCreateOrderLabel: UILabel!
    @IBOutlet weak var statusOrderLabel: UILabel!
    @IBOutlet weak var totalInvoiceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4.0
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 16
    }
    
    func configure(_ dateCreate: String, status: String) {
        self.dateCreateOrderLabel.text = dateCreate
        self.statusOrderLabel.text = status
    }
}
