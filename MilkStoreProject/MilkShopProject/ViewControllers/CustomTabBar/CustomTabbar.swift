//
//  CustomTabbar.swift
//  MilkShopProject
//
//  Created by CongDev on 9/4/25.
//

import UIKit

class CustomTabbar: UIView {
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var cartLabel: UILabel!
    @IBOutlet weak var cartImageView: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    var itemTapped: ((_ tab: Int) -> Void)?
    var indexSelect: Int = 0 {
        didSet {
            homeImageView.tintColor = indexSelect == 0 ? .black : .gray
            cartImageView.tintColor = indexSelect == 1 ? .black : .gray
            settingImageView.tintColor = indexSelect == 2 ? .black : .gray
            homeLabel.textColor = indexSelect == 0 ? .black : .gray
            cartLabel.textColor = indexSelect == 1 ? .black : .gray
            settingLabel.textColor = indexSelect == 2 ? .black : .gray
        }
    }
    
    init(frame: CGRect, idx : Int) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "CustomTabbar"
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        DispatchQueue.main.async {
//            self.mainView.roundCorners([.topLeft, .topRight], radius: 20)
        }
    }
    
    @IBAction func didClickTab(_ sender: UIButton) {
        itemTapped?(sender.tag)
        indexSelect = sender.tag
    }
}
