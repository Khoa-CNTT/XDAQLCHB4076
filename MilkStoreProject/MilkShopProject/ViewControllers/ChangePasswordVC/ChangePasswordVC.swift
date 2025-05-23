//
//  ChangePasswordVC.swift
//  MilkShopProject
//
//  Created by CongDev on 10/5/25.
//

import UIKit
import Firebase

class ChangePasswordVC: BaseViewController {

    @IBOutlet weak var confirmNewPasswordTF: UITextField! {
        didSet {
            self.confirmNewPasswordTF.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var newPasswordTF: UITextField! {
        didSet {
            self.newPasswordTF.isSecureTextEntry = true
        }
    }
    
    @IBOutlet weak var passwordOldTF: UITextField! {
        didSet {
            self.passwordOldTF.isSecureTextEntry = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func didTapConfirmButton(_ sender: Any) {
        let passwordOld = passwordOldTF.text ?? ""
        let newPassword = newPasswordTF.text ?? ""
        let confirmNewPassword = confirmNewPasswordTF.text ?? ""
        
        guard let userId = Auth.auth().currentUser?.uid else {
            self.showToast(message: "Không tìm thấy người dùng")
            return }
        
        if newPassword != confirmNewPassword {
            self.showAlert(title: "Lỗi", message: "Mật khẩu xác nhận không khớp!")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("usernew").document(userId)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Lỗi khi lấy thông tin người dùng: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if passwordOld.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty {
                    self.dismiss()
                    return
                }
                
                self.showHUD(label: "Đang xử lý...")
                FirebaseUploader.shared.changeUserPassword(
                    oldPassword: passwordOld,
                    newPassword: newPassword
                ) { error in
                    if let _ = error {
                        self.dismissHUD()
                        self.showAlert(title: "Lỗi", message: "Mật khẩu cũ không đúng!")
                    } else {
                        self.dismissHUD()
                        self.showAlert(title: "Thành công", message: "Đổi mật khẩu thành công!") { _ in
                            self.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: completion)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
