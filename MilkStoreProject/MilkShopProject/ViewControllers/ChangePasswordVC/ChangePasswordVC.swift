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
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("usernew").document(userId)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Lỗi khi lấy thông tin người dùng: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if passwordOld.isEmpty || newPassword.isEmpty || confirmNewPasswordTF.isEmpty {
                    self.dismiss()
                    return
                }
                
                FirebaseUploader.shared.changeUserPassword(
                    oldPassword: passwordOld,
                    newPassword: newPassword
                ) { error in
                    if let error = error {
                        self.showToast(message: "Lỗi đổi mật khẩu: \(error.localizedDescription)")
                    } else {
                        self.showToast(message: "Đổi mật khẩu thành công!")
                        self.dismiss()
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
