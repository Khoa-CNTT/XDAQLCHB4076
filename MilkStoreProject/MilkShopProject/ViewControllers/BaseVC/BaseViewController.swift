//
//  BaseViewController.swift
//
//

import UIKit
import SwifterSwift
import MBProgressHUD
import StoreKit
import Lottie
import AVFoundation
import AudioToolbox

// MARK: - Definitions

class BaseViewController: UIViewController {
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultStyle()
        setupUI()
        setupData()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        //        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = true
        //        AppUtility.lockOrientation(.portrait)
        updateData()
    }
    
    var isCancel: Bool = false
    
    func updateData() {}
    
    private func defaultStyle() {
    }
    
    // MARK: - Public Functions
    func setupUI() {}
    
    
    func setupData() {}
    deinit {
        debugPrint("\(String(describing: type(of: self))) \(#function)")
    }
    
    func showNetworkError() {
        showAlert(title: "Please connect to the network", message: nil)
    }
    
    func showHUD(progressLabel: String){
        isCancel = false
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = progressLabel
            progressHUD.button.setTitle("Cancel", for: .normal)
            progressHUD.button.addTarget(self, action: #selector(self.dismissHUD(isAnimated:)), for: .touchUpInside)
        }
    }
    
    func showHUD(label: String){
        isCancel = false
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = label
        }
    }
    
    @objc func dismissHUD(isAnimated:Bool) {
        isCancel = true
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
    func configureAnimation(_ view: LottieAnimationView,_ nameAnimation: String, isPlay: Bool, speed: CGFloat = 0.0) {
        view.animation = LottieAnimation.named(nameAnimation)
        view.contentMode = .scaleToFill
//        view.animationSpeed = speed
        view.loopMode = .loop
        isPlay ? view.play() : view.pause()
    }
    
    func openLink(link: String){
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    func showAlert( alert: UIAlertController) {
        guard presentedViewController != nil else {
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func hideKeyboard() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
//    func showIAP() {
//        let iapVC = IAPVC()
//        self.present(vc: iapVC)
//    }
    
    func isValidPassword(_ password: String, confirmation: String) -> Bool {
        let minLength = 8
        let uppercaseRegex = try! NSRegularExpression(pattern: "[A-Z]")
        let lowercaseRegex = try! NSRegularExpression(pattern: "[a-z]")
        let numberRegex = try! NSRegularExpression(pattern: "[0-9]")
        let specialCharRegex = try! NSRegularExpression(pattern: "[!@#$%^&*()_+\\-=\\[\\]{};':\",./<>?]")

        let isLengthValid = password.count >= minLength
        let containsUppercase = uppercaseRegex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil
        let containsLowercase = lowercaseRegex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil
        let containsNumber = numberRegex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil
        let containsSpecialCharacter = specialCharRegex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil

        let passwordsMatch = password == confirmation

        return isLengthValid && containsUppercase && containsLowercase && containsNumber && containsSpecialCharacter && passwordsMatch
    }
    
    func formattedDescription(from rawText: String) -> String {
        var cleaned = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "\"", with: "")
        
        let lines = cleaned.components(separatedBy: "\n").map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "" : "• \(trimmed)"
        }

        return lines.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }
    
    func convertPriceToInt(_ priceString: String) -> Int? {
        let cleanedPrice = priceString.replacingOccurrences(of: " đ", with: "")
        let cleanedPriceWithoutDot = cleanedPrice.replacingOccurrences(of: ".", with: "")
        
        return Int(cleanedPriceWithoutDot)
    }
}


