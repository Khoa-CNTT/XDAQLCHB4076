//
//  AddressCell.swift
//  MilkShopProject
//
//  Created by CongDev on 7/5/25.
//

import UIKit

protocol AddressCellDelegate: AnyObject {
    func didTapAddAddressButton()
}

class AddressCell: UITableViewCell {

    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    weak var delegate: AddressCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTapAddAddressButton(_ sender: Any) {
        self.delegate?.didTapAddAddressButton()
    }
    
}
