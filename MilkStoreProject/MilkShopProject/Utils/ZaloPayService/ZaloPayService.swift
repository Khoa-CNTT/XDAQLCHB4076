//
//  ZaloPayService.swift
//  MilkShopProject
//
//  Created by CongDev on 8/5/25.
//

import Foundation
import UIKit
import Alamofire

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
    
    func refundOrder(zpTransId: String, amount: Int, completion: @escaping (Bool, String) -> Void) {
        let appId = 2554
        let currentDate = Date()
        let timestamp = Int(currentDate.timeIntervalSince1970 * 1000)
        let description = "Refund for transaction #\(zpTransId)"
        let mRefundId = "\(getCurrentDateInFormatYYMMDD())_\(appId)_\(Int.random(in: 10000000...99999999))"

        let hmacInput = "\(appId)|\(zpTransId)|\(amount)|\(description)|\(timestamp)"
        let mac = hmacInput.hmac(algorithm: .SHA256, key: "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn")

        let params: [String: Any] = [
            "app_id": appId,
            "m_refund_id": mRefundId,
            "zp_trans_id": zpTransId,
            "amount": amount,
            "timestamp": timestamp,
            "description": description,
            "mac": mac
        ]

        AF.request("https://sb-openapi.zalopay.vn/v2/refund", method: .post, parameters: params, encoding: URLEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("✅ Refund API response: \(value)")

                    if let dict = value as? [String: Any],
                       let returnCode = dict["return_code"] as? Int,
                       let returnMessage = dict["return_message"] as? String {

                        switch returnCode {
                        case 1:
                            // Thành công
                            completion(true, "Hoàn tiền thành công")
                        case 2:
                            // Đã hoàn trước đó
                            completion(true, "Giao dịch đã được hoàn trước đó")
                        case 3:
                            // Đang xử lý
                            completion(true, "Hoàn tiền đang được xử lý, vui lòng kiểm tra sau")
                        default:
                            // Các mã lỗi khác
                            completion(false, returnMessage)
                        }
                    } else {
                        completion(false, "Không parse được response từ ZaloPay")
                    }

                case .failure(let error):
                    print("❌ Refund error: \(error)")
                    completion(false, "Lỗi kết nối đến ZaloPay: \(error.localizedDescription)")
                }
            }
    }

    
    /// Lấy zp_trans_id từ ZaloPay bằng appTransId
    func fetchZPTransId(appTransId: String, completion: @escaping (String?) -> Void) {
        let appId = 2554
        let key = "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn"
        let hmacInput = "\(appId)|\(appTransId)|\(key)"
        let mac = hmacInput.hmac(algorithm: .SHA256, key: key)
        
        let params: [String: Any] = [
            "app_id": appId,
            "app_trans_id": appTransId,
            "mac": mac
        ]
        
        AF.request("https://sb-openapi.zalopay.vn/v2/query", method: .post, parameters: params, encoding: URLEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let dict = value as? [String: Any] {
                        if let zpTransIdInt = dict["zp_trans_id"] as? Int64 {
                            completion(String(zpTransIdInt))
                        } else if let zpTransIdInt = dict["zp_trans_id"] as? Int {
                            completion(String(zpTransIdInt))
                        } else if let zpTransIdStr = dict["zp_trans_id"] as? String {
                            completion(zpTransIdStr)
                        } else {
                            print("Không tìm thấy zp_trans_id trong response: \(value)")
                            completion(nil)
                        }
                    } else {
                        print("Không tìm thấy zp_trans_id trong response: \(value)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Lỗi khi gọi /v2/query: \(error)")
                    completion(nil)
                }
            }
    }
}
