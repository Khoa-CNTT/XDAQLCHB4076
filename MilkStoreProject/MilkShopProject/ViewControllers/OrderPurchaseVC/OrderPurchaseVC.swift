//
//  OrderPurchaseVC.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit
import LZViewPager

class OrderPurchaseVC: UIViewController {

    @IBOutlet weak var viewPager: LZViewPager!
    
    private var subControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewPager()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        self.back()
    }
    
    private func setupViewPager() {
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.hostController = self
        updateUIViewPage()
    }
    
    private func updateUIViewPage() {
        
        let statuses = [Global.orderConfirm, Global.orderWaitShip, Global.orderShipped, Global.orderCompleted, Global.orderCancel]
        subControllers = statuses.map({ status in
            let vc = TrackingOrderVC()
            vc.title = status
            vc.statusOrder = status
            return vc
        })
        viewPager.reload()
    }
}

extension OrderPurchaseVC: LZViewPagerDataSource, LZViewPagerDelegate {
    func numberOfItems() -> Int {
        return self.subControllers.count
    }
    
    func controller(at index: Int) -> UIViewController {
        return self.subControllers[index]
    }
    
    func button(at index: Int) -> UIButton {
        let button = LZButton()
        return button
    }
    
    func didSelectButton(at index: Int) {}
    
    func leftMarginForHeader() -> CGFloat {
        return 0
    }
    
    func rightMarginForHeader() -> CGFloat {
        return 0
    }
    
    func widthForButton(at index: Int) -> CGFloat {
        if index == 0 {
            return 200
        } else if index == 4 {
            return 100
        }
        return 156
    }
    
    func heightForHeader() -> CGFloat {
        return 48
    }
    
    func shouldShowIndicator() -> Bool {
        return false
    }
    
    func backgroundColorForHeader() -> UIColor {
        return .clear
    }
}

class LZButton: UIButton {
    var backgroundCustomView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view = UIView()
        self.insertSubview(view, at: 0)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layerBorderColor = UIColor(hexString: "#262626")
        view.layerBorderWidth = 1
        view.layerCornerRadius = 24
        view.isUserInteractionEnabled = false
        backgroundCustomView = view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: isSelected ? 16 : 16)
            self.setTitleColorForAllStates(isSelected ? UIColor(hexString: "#FFFFFF"): UIColor(hexString: "#262626"))
            backgroundCustomView?.backgroundColor = UIColor(hexString: isSelected ? "#262626" : "#FFFFFF")
            self.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.isUserInteractionEnabled = true
            })
        }
    }
}
