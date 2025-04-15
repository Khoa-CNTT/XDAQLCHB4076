//
//  SplashVC.swift
//  MilkShopProject
//
//  Created by CongDev on 24/3/25.
//

import UIKit

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            AppDelegate.setRoot(UDHelper.isLoginSuccess ? TabbarCustomController() : LoginVC(), isNavi: true)
        }
    }

}
