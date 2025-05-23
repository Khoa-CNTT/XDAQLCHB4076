//
//  AppDelegate.swift
//  MilkShopProject
//
//  Created by CongDev on 24/3/25.
//

import UIKit
import zpdk
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ZaloPaySDK.sharedInstance()?.initWithAppId(2554, uriScheme: "demozpdk://app", environment: .sandbox)
        FirebaseApp.configure()
        configWindow()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "demozpdk" {
            return ZaloPaySDK.sharedInstance().application(app, open: url, sourceApplication: "vn.com.vng.zalopay", annotation: nil)
        }
        
        return false
    }
    
    func configWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashVC = UINavigationController(rootViewController: SplashVC())
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
    }
}


extension AppDelegate {
    static func setRoot(_ viewController: UIViewController, isNavi: Bool = false) {
        guard let window = UIWindow.key else { return }
        
        UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            if isNavi {
                if let navController = viewController as? UINavigationController {
                    window.rootViewController = navController
                } else {
                    window.rootViewController = UINavigationController(rootViewController: viewController)
                }
            } else {
                window.rootViewController = viewController
            }
            window.makeKeyAndVisible()
            UIView.setAnimationsEnabled(oldState)
        })
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
