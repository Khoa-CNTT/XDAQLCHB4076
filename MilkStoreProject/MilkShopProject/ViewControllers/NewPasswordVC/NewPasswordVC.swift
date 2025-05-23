//
//  NewPasswordVC.swift
//  MilkShopProject
//
//  Created by CongDev on 15/5/25.
//

import UIKit
import AnimatedField
import Firebase
import FirebaseAuth

class NewPasswordVC: BaseViewController {

    @IBOutlet weak var confirmPwAnimatedField: AnimatedField!
    @IBOutlet weak var passwordNewAnimatedField: AnimatedField!
    
    var phoneNumber: String?
    private var newPassword: String = ""
    private var confirmPassword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        hideKeyboardWhenTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupAnimatedField()
    }
    
    @IBAction func didTapChangePwButton(_ sender: Any) {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showAlert(title: "Thông báo", message: "Vui lòng nhập đầy đủ mật khẩu")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Thông báo", message: "Mật khẩu xác nhận không khớp")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("usernew").whereField("phone", isEqualTo: phoneNumber ?? "").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                return
            }
            
            if let document = snapshot?.documents.first {
                document.reference.updateData(["password": self.newPassword]) { error in
                    if let error = error {
                        self.showAlert(title: "Lỗi", message: error.localizedDescription)
                        return
                    }
                    
                    if let user = Auth.auth().currentUser {
                        user.updatePassword(to: self.newPassword) { error in
                            if let error = error {
                                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                                return
                            }
                            
                            // Đăng xuất và quay về màn login
                            do {
                                try Auth.auth().signOut()
                                self.showAlert(title: "Thành công", message: "Đổi mật khẩu thành công") { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        AppDelegate.setRoot(LoginVC(), isNavi: true)
                                    }
                                }
                            } catch {
                                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setupAnimatedField() {
        var format = AnimatedFieldFormat()
        format.titleFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(400))
        format.textFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight(500))
        format.alertColor = .red
        format.alertFieldActive = false
        format.titleAlwaysVisible = true
        format.alertFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(400))
        
        passwordNewAnimatedField.format = format
        passwordNewAnimatedField.placeholder = "Mật khẩu mới (min 6, max 10)"
        passwordNewAnimatedField.dataSource = self
        passwordNewAnimatedField.delegate = self
        passwordNewAnimatedField.type = .password(6, 10)
        passwordNewAnimatedField.isSecure = true
        passwordNewAnimatedField.showVisibleButton = true
        
        confirmPwAnimatedField.format = format
        confirmPwAnimatedField.placeholder = "Xác nhận mật khẩu mới"
        confirmPwAnimatedField.dataSource = self
        confirmPwAnimatedField.delegate = self
        confirmPwAnimatedField.type = .password(6, 10)
        confirmPwAnimatedField.isSecure = true
        confirmPwAnimatedField.showVisibleButton = true
    }
}

extension NewPasswordVC: AnimatedFieldDelegate, AnimatedFieldDataSource {
    func animatedField(_ animatedField: AnimatedField, didSecureText secure: Bool) {
        if animatedField == passwordNewAnimatedField {
            confirmPwAnimatedField.secureField(secure)
        }
    }
    
    func animatedField(_ animatedField: AnimatedField, didChangeText text: String) {
        if animatedField == passwordNewAnimatedField {
            newPassword = text
        } else if animatedField == confirmPwAnimatedField {
            confirmPassword = text
        }
    }
}

extension NewPasswordVC {
    @objc func hideKeyboardWhenTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
