//
//  TabbarCustomController.swift
//  MilkShopProject
//
//  Created by CongDev on 9/4/25.
//

import UIKit

class TabbarCustomController: UITabBarController {
    
    var customTabBar: CustomTabbar!
    var tabBarHeight = 80.0
    private var homeVC = HomeVC()
    private var cartVC = NotificationUserVC()
    private var settingVC = AccountVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [homeVC, cartVC, settingVC]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.setupCustomTabMenu()
        }
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
    
    func setupCustomTabMenu() {
        var frame = tabBar.frame
        frame.size.height = 80
        tabBar.isHidden = true
        customTabBar = CustomTabbar(frame: frame , idx: selectedIndex)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.clipsToBounds = true
        customTabBar.frame = frame
        customTabBar.itemTapped = changeTab(tab:)
        view.addSubview(customTabBar)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor,constant: 0),
            customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor,constant: 0),
            customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        view.layoutIfNeeded()
    }
}
