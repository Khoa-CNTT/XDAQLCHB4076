//
//  ZaloPayService.swift
//  MilkShopProject
//
//  Created by CongDev on 8/5/25.
//

import Foundation
import UIKit

class ZaloPayService {
    static let shared = ZaloPayService()
    
    func createOrder(amount: Int, completion: @escaping (String?) -> Void) {
        let currentDate = Date()
        let random = Int.random(in: 0...10000000)
        let appTransPrefix = getCurrentDateInFormatYYMMDD()
        let appTransID = "\(appTransPrefix)_\(random)"
        
        let appId = 2554
        let appUser = "demo"
        let appTime = Int(currentDate.timeIntervalSince1970 * 1000)
        let embedData = "{}"
        let item = "[]"
        let description = "Merchant payment for order #" + appTransID
        let hmacInput = "\(appId)|\(appTransID)|\(appUser)|\(amount)|\(appTime)|\(embedData)|\(item)"
        
        let mac = hmacInput.hmac(algorithm: .SHA256, key: "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn")

        var request = URLRequest(url: URL(string: "https://sb-openapi.zalopay.vn/v2/create")!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let postString = "app_id=\(appId)&app_user=\(appUser)&app_time=\(appTime)&amount=\(amount)&app_trans_id=\(appTransID)&embed_data=\(embedData)&item=\(item)&description=\(description)&mac=\(mac)"
        request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let zpToken = json["zp_trans_token"] as? String {
                completion(zpToken)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func getCurrentDateInFormatYYMMDD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: Date())
    }
    
    func installSandbox(from viewController: UIViewController) {
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: .alert)
        let installLink = "https://stcstg.zalopay.com.vn/ps_res/ios/enterprise/sandboxmer/external/5.8.0/install.html"
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let installAction = UIAlertAction(title: "Install App", style: .default) { _ in
            guard let url = URL(string: installLink) else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(installAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func isZaloPayInstalled() -> Bool {
        guard let url = URL(string: "zalopay://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
