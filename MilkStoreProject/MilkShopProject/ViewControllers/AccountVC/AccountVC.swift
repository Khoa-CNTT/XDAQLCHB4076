//
//  AccountVC.swift
//  MilkShopProject
//
//  Created by CongDev on 9/5/25.
//

import UIKit
import Firebase


class AccountVC: BaseViewController {
    
    @IBOutlet weak var containerPopupView: UIView!
    @IBOutlet weak var popupLogoutView: UIView!
    @IBOutlet weak var phoneNumberUserLabel: UILabel!
    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var infoUserTableView: UITableView!
    
    private var infoType: [InfoUserType] = InfoUserType.allCases
    private var nameUser = ""
    private var phoneNumberUser = ""
    private var adminInfoType: [AdminManagerType] = AdminManagerType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView(infoUserTableView, InfoCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserInfo()
    }
    
    @IBAction func didTapAgreeButton(_ sender: Any) {
        self.logOut()
        self.popupLogoutView.isHidden = true
        self.containerPopupView.isHidden = true
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.popupLogoutView.alpha = 0
        self.containerPopupView.alpha = 0
    }
    
    private func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("usernew").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let phoneNumber = document.data()?["phone"] as? String ?? "Unknown"
                let name = document.data()?["username"] as? String ?? "Unknown"
                DispatchQueue.main.async {
                    self.nameUserLabel.text = name
                    self.phoneNumberUserLabel.text = phoneNumber
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            UDHelper.isLoginSuccess = false
            Global.isDimissBottomSheet = true
            AppDelegate.setRoot(LoginVC())
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func animateLogoutPopup() {
        self.containerPopupView.alpha = 0
        self.popupLogoutView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.containerPopupView.alpha = 1
        }) { _ in
            self.popupLogoutView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.popupLogoutView.alpha = 1
            })
        }
    }
}

extension AccountVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UDHelper.roleUser == true ? adminInfoType.count : infoType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: InfoCell.self, for: indexPath)
        let role = UDHelper.roleUser
        
        if role {
            let item = adminInfoType[indexPath.row]
            cell.configure(image: item.iconName ?? UIImage(), name: item.name)
        } else {
            let item = infoType[indexPath.row]
            cell.configure(image: item.iconName ?? UIImage(), name: item.name)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UDHelper.roleUser {
            switch adminInfoType[indexPath.row] {
            case .changeInfo:
                let vc = ChangeInfoVC()
                vc.callBack = { [weak self] name,phone in
                    guard let self = self else { return }
                    
                    self.nameUserLabel.text = name
                    self.phoneNumberUserLabel.text = phone
                    Global.isDimissBottomSheet = false
                }
                self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 0)
            case .changePassword:
                let vc = ChangePasswordVC()
                self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 0)
            case .client:
                let vc = ClientsVC()
                self.push(vc)
            case .invoice:
                let vc = InvoiceVC()
                self.push(vc)
            case .product:
                let vc = ProductsVC()
                self.push(vc)
            case .order:
                let vc = OrderPurchaseVC()
                self.push(vc)
            case .logout:
                animateLogoutPopup()
            }
        } else {
            switch infoType[indexPath.row] {
            case .changeInfo:
                let vc = ChangeInfoVC()
                vc.callBack = { [weak self] name,phone in
                    guard let self = self else { return }
                    
                    self.nameUserLabel.text = name
                    self.phoneNumberUserLabel.text = phone
                    Global.isDimissBottomSheet = false
                }
                self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 0)
            case .changePassword:
                let vc = ChangePasswordVC()
                self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 0)
            case .address:
                let vc = AddressVC()
                self.push(vc)
            case .order:
                let vc = OrderPurchaseVC()
                self.push(vc)
            case .logout:
                animateLogoutPopup()
            default:
                break
            }
        }
        
    }
}
