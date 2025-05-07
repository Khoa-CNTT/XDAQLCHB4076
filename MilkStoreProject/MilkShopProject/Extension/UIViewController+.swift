//
//  UIViewController+.swift
//  AIPhotoProject

import Foundation
import AVFoundation
import Contacts
import Photos
import AssetsLibrary
import SwifterSwift
import UIKit
import MBProgressHUD

extension UIViewController {
    
    func alert(title: String? = nil, message: String? = nil, actions: [UIAlertAction], style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        actions.forEach({ alert.addAction($0) })
        present(alert, animated: true, completion: nil)
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width / 2 - 150, y: 100, width: 300, height: 60))
        toastLabel.layer.cornerRadius = 30
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 15)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    func pushViewPrenset(vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        vc.modalPresentationStyle = .overFullScreen
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
    
    func dissmissViewPresent() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    func showAlertSetting(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            // Take the user to Settings app to possibly change permission.
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        alert.addAction(settingsAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertAccept(title:String , message:String,  handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let settingsAction = UIAlertAction(title: "OK", style: .destructive, handler: handler)
        alert.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
//        let when = DispatchTime.now() + 5
//        DispatchQueue.main.asyncAfter(deadline: when){
//            // your code with delay
//            alert.dismiss(animated: true, completion: nil)
//        }
    }
    
    func push(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func back() {
        navigationController?.popViewController(animated: true)
    }

    func back(to viewController: UIViewController) {
        navigationController?.popToViewController(viewController, animated: true)
    }
    
    func present(vc:UIViewController) {
        let vc = vc
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
       
    }
    
    func presentPasscode(vc : UIViewController) {
        let vc = vc
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func showHUD() {
        DispatchQueue.main.async {
//            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }

    func dismissHUD() {
        DispatchQueue.main.async {
//            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func showShortLoading() {
        self.showHUD()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismissHUD()
        }
    }
    
    func openBottomSheet(vc: UIViewController, ratioView height: CGFloat = 0.5, lineGrabber: Bool = false, corner: CGFloat = 10){
        vc.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = lineGrabber
                sheet.preferredCornerRadius = corner
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { context in
                        height * context.maximumDetentValue
                    })]
                } else {
                    sheet.detents = [.medium()]
                }
            }
        } else {}

        self.present(vc, animated: true, completion: nil)
    }
    
     func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentAudioSettings()
            return
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        @unknown default:
            break
        }
    }

     func presentAudioSettings() {
        let alertController = UIAlertController(title: "Alert",
                                                message: "Camera access is denied, please go to settings to grant permission",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
            }
        })
        present(alertController, animated: true)
    }
    
    //MARK: - Check Permission -
    //LIBRARY
    func goSettingPermission() {
//        DispatchQueue.main.async {
//            guard let currentVC = UIApplication.topViewController() else { return }
//            let message = "This app requires access to Library to proceed. Go to Settings to grant access."
//            currentVC.showAlert(title: "Opps",
//                                message: message,
//                                buttonTitles: ["OK", "Settings"], highlightedButtonIndex: 1) { index in
//                if index == 1 {
//                    guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
//                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//                }
//            }
//        }
    }
    
    func goSettingPermissionSplash(handleOK: @escaping () -> Void) {
//        DispatchQueue.main.async {
//            guard let currentVC = UIApplication.topViewController() else { return }
//            let message = "This app requires access to Library to proceed. Go to Settings to grant access."
//            currentVC.showAlert(title: "Opps",
//                                message: message,
//                                buttonTitles: ["OK", "Settings"], highlightedButtonIndex: 1) { index in
//                if index == 1 {
//                    guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
//                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//                }else {
//                    handleOK()
//                }
//            }
//        }
    }
    
    //CONTACTS
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
//        guard let currentVC = UIApplication.topViewController() else { return }
//        let message = "This app requires access to Contacts to proceed. Go to Settings to grant access."
//        currentVC.showAlert(title: "Opps",
//                            message: message,
//                            buttonTitles: ["OK", "Settings"], highlightedButtonIndex: 1) { index in
//            if index == 1 {
//                guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
//                UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//            }
//        }
    }
    
    func convertInt64toString(sizeOnDisk: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        return formatter.string(fromByteCount: Int64(sizeOnDisk))
    }
    
    func setUpTableView(_ tableView: UITableView, _ cell: UITableViewCell.Type, completion: (() -> ())? = nil){
        tableView.dataSource = self as? any UITableViewDataSource
        tableView.delegate = self as? any UITableViewDelegate
        tableView.register(nibWithCellClass: cell.self)
        tableView.reloadData()
    }
    
    func setUpCollectionView(_ collectionView: UICollectionView, _ cell: UICollectionViewCell.Type, completion: (() -> ())? = nil){
        collectionView.dataSource = self as? any UICollectionViewDataSource
        collectionView.delegate = self as? any UICollectionViewDelegate
        collectionView.register(nibWithCellClass: cell.self)
        collectionView.reloadData()
    }
}

extension UIViewController {
    var isModal: Bool {
        if let presentingViewController = self.presentingViewController {
            return true
        }
        if let navigationController = self.navigationController, navigationController.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if let tabBarController = self.tabBarController, tabBarController.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
}
