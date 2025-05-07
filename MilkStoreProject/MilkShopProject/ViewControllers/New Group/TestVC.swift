//
//  TestVC.swift
//  MilkShopProject
//
//  Created by CongDev on 1/4/25.
//

import UIKit
import zpdk

class TestVC: UIViewController {
    
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var btnCreateOrder: UIButton!
    @IBOutlet weak var zpTransToken: UITextField!
    @IBOutlet weak var textAmount: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        installSandbox()
//        installZalo()
    }
    
    func installSandbox() {
        let alert = UIAlertController(title: "Info", message: "Please install ZaloPay", preferredStyle: .alert)
        let installLink = "https://stcstg.zalopay.com.vn/ps_res/ios/enterprise/sandboxmer/external/5.8.0/install.html"
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
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
        self.present(alert, animated: true, completion: nil)
    }
    
    func installZalo() {
        let alert = UIAlertController(title: "Info", message: "Please install Zalo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        let installAction = UIAlertAction(title: "Install App", style: .default) { (action) in
            ZaloPaySDK.sharedInstance()?.navigateToZaloStore()
        }
        alert.addAction(cancelAction)
        alert.addAction(installAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCreateOrderClick(_ sender: Any) {
        lbResult.text = ""
        
        let currentDate = Date()
        let random = Int.random(in: 0...10000000)
        
        let appTransPrefix = GetCurrentDateInFormatYYMMDD()
        
        let appTransID = "\(appTransPrefix)_\(random)"
        
        let appId = 2554
        let appUser = "demo"
        let appTime = Int(currentDate.timeIntervalSince1970*1000)
        print(appTime)
        let embedData = "{}"
        let item = "[]"
        let description = "Merchant payment for order #" + appTransID
        
        let AmountInString: String = String(self.textAmount.text!)
        
        let hmacInput = "\(appId)" + "|" + "\(appTransID)" + "|" + appUser + "|" + "\(AmountInString)" + "|" + "\(appTime)" + "|"
        + embedData + "|" + item
        
        let mac = hmacInput.hmac(algorithm: CryptoAlgorithm.SHA256, key: "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn")//2554 sb
        
        //merchant can change the url to merchant's server endpoint which handle create zalopay order
        let url = URL(string: "https://sb-openapi.zalopay.vn/v2/create")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let postString = "app_id=\(appId)&app_user=\(appUser)&app_time=\(appTime)&amount=\(AmountInString)&app_trans_id=\(appTransID)&embed_data=\(embedData)&item=\(item)&description=\(description)&mac=\(mac)"
        request.httpBody = postString.data(using: .utf8)
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return // check for fundamental networking error
                }
                
                // Getting values from JSON Response
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                    let returncode =  jsonResponse?.object(forKey: "return_code") as? Int
                    if returncode != 1 {
                        DispatchQueue.main.async {
                            self.lbResult.text = "Create order failed, error:\(String(describing: returncode))"
                        }
                    } else {
                        let zptranstoken = jsonResponse?.object(forKey: "zp_trans_token") as? String
                        DispatchQueue.main.async {
                            self.zpTransToken.text = zptranstoken
                        }
                    }
                } catch _ {
                    print ("OOps not good JSON formatted response")
                }
            }
            task.resume()
        }
    }
    
    @IBAction func onPayClick(_ sender: Any) {
        self.lbResult.text = ""
        ZaloPaySDK.sharedInstance()?.paymentDelegate = self
        ZaloPaySDK.sharedInstance()?.payOrder(zpTransToken.text)
    }
    
    func GetCurrentDateInFormatYYMMDD() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyMMdd"
        return dateFormatterPrint.string(from:Date())
    }
}

extension TestVC: ZPPaymentDelegate {
    func paymentDidSucceeded(_ transactionId: String!, zpTranstoken: String!, appTransId: String!) {
        lbResult.text = "Thanh toán thành công"
        // Handle Success
    }
    
    func paymentDidCanceled(_ zpTranstoken: String!, appTransId: String!) {
        lbResult.text = "Thanh toán đã hủy"
        // Handle Cancel
    }
    
    func paymentDidError(_ errorCode: ZPPaymentErrorCode, zpTranstoken : String!, appTransId: String!) {
        lbResult.text = "Thanh toán thất bại, error: \(errorCode.rawValue)"
        // Handle error
    }
}
