//
//  AuthenPhoneNumberVC.swift
//  MilkShopProject
//
//  Created by CongDev on 15/5/25.
//

import UIKit
import FirebaseAuth

class AuthenPhoneNumberVC: BaseViewController {

    @IBOutlet weak var codeOneTF: UITextField!
    @IBOutlet weak var codeTwoTF: UITextField!
    @IBOutlet weak var codeThreeTF: UITextField!
    @IBOutlet weak var codeFourTF: UITextField!
    @IBOutlet weak var codeFiveTF: UITextField!
    @IBOutlet weak var codeSixTF: UITextField!
    
    var verificationID: String?
    var phoneNumber: String?
    private var textFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        textFields = [codeOneTF, codeTwoTF, codeThreeTF, codeFourTF, codeFiveTF, codeSixTF]
        textFields.forEach { textField in
            textField.delegate = self
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count == 1 {
            if let index = textFields.firstIndex(of: textField), index < textFields.count - 1 {
                textFields[index + 1].becomeFirstResponder()
            }
        }
    }
    
    @IBAction func didTapResendCodeBtn(_ sender: UIButton) {
        guard let phoneNumber = phoneNumber else { return }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] (verificationID, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Lỗi", message: error.localizedDescription)
                return
            }
            
            if let verificationID = verificationID {
                self.verificationID = verificationID
                self.showAlert(title: "Thông báo", message: "Mã xác thực mới đã được gửi")
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
    
    private func verifyOTP() {
        guard let verificationID = verificationID else { return }
        
        let otpCode = textFields.compactMap { $0.text }.joined()
        guard otpCode.count == 6 else {
            showAlert(title: "Thông báo", message: "Vui lòng nhập đầy đủ mã xác thực")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otpCode)
        
        Auth.auth().signIn(with: credential) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Lỗi", message: "Mã xác thực không đúng hoặc đã hết hạn")
                return
            }
            
            if result != nil {
                let vc = NewPasswordVC()
                vc.phoneNumber = self.phoneNumber
                self.push(vc)
            }
        }
    }
}

extension AuthenPhoneNumberVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count == 1 {
            if let index = textFields.firstIndex(of: textField), index < textFields.count - 1 {
                DispatchQueue.main.async {
                    self.textFields[index + 1].becomeFirstResponder()
                }
            } else if let index = textFields.firstIndex(of: textField), index == textFields.count - 1 {
                DispatchQueue.main.async {
                    self.verifyOTP()
                }
            }
        }
        
        return updatedText.count <= 1
    }
}
