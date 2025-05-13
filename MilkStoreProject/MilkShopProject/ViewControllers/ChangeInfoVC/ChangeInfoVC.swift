//
//  ChangeInfoVC.swift
//  MilkShopProject
//
//  Created by CongDev on 9/5/25.
//

import UIKit
import Firebase

class ChangeInfoVC: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var gmailTF: UITextField!
    @IBOutlet weak var nameUserTF: UITextField!
    
    var callBack: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameUserTF.delegate = self
        phoneTF.delegate = self
        gmailTF.delegate = self
        
        nameUserTF.keyboardType = .default
        nameUserTF.autocorrectionType = .no
        nameUserTF.spellCheckingType = .no
        nameUserTF.autocapitalizationType = .none
        nameUserTF.returnKeyType = .done
        
        phoneTF.keyboardType = .numberPad
        phoneTF.autocorrectionType = .no
        phoneTF.spellCheckingType = .no
        phoneTF.autocapitalizationType = .none
        phoneTF.returnKeyType = .done
        
        gmailTF.keyboardType = .default
        gmailTF.autocorrectionType = .no
        gmailTF.spellCheckingType = .no
        gmailTF.autocapitalizationType = .none
        gmailTF.returnKeyType = .done
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
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
                let oldName = document.data()?["username"] as? String ?? ""
                let oldEmail = document.data()?["email"] as? String ?? ""
                let oldPhone = document.data()?["phone"] as? String ?? ""
                let password = document.data()?["password"] as? String ?? ""

                let name = (self.nameUserTF.text ?? "").isEmpty ? oldName : self.nameUserTF.text!
                let email = (self.gmailTF.text ?? "").isEmpty ? oldEmail : self.gmailTF.text!
                let phone = (self.phoneTF.text ?? "").isEmpty ? oldPhone : self.phoneTF.text!

                FirebaseUploader.shared.updateUserProfile(
                    name: name,
                    email: email,
                    phoneNumber: phone,
                    currentPassword: password
                ) { error in
                    if let error = error {
                        if error.localizedDescription.contains("xác thực") {
                            self.showToast(message: "Vui lòng kiểm tra email và xác thực địa chỉ email mới. Sau khi xác thực, bạn có thể thay đổi email.")
                        } else {
                            self.showToast(message: "Lỗi khi cập nhật thông tin: \(error.localizedDescription)")
                            print("error:\(error.localizedDescription)")
                        }
                    } else {
                        self.showToast(message: "Cập nhật thông tin thành công")
                        Global.isDimissBottomSheet = true
                        self.callBack?(name,phone)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.dismiss()
                        }
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
