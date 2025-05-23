//
//  ForgotPasswordVC.swift
//  MilkShopProject
//
//  Created by CongDev on 15/5/25.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordVC: BaseViewController {

    @IBOutlet weak var numberPhoneTF: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    private var isValidEmail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTap()
        setupUI()
    }
    
    override func setupUI() {
        numberPhoneTF.delegate = self
        numberPhoneTF.keyboardType = .emailAddress
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func updateContinueButtonState() {
        continueButton.isEnabled = isValidEmail
        continueButton.alpha = isValidEmail ? 1.0 : 0.5
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        self.back()
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        guard let email = numberPhoneTF.text, !email.isEmpty else { return }
        
        self.showHUD(label: "Đang kiểm tra...")
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] (methods, error) in
            print("DEBUG - Email: \(email)")
            print("DEBUG - Methods: \(String(describing: methods))")
            print("DEBUG - Error: \(String(describing: error))")
            
            if let error = error {
                self?.dismissHUD()
                self?.showAlert(title: "Lỗi", message: error.localizedDescription)
                return
            }
            
            self?.showHUD(label: "Đang gửi email...")
            Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                self?.dismissHUD()
                if let error = error {
                    self?.showAlert(title: "Lỗi", message: error.localizedDescription)
                } else {
                    self?.showAlert(title: "Thành công", message: "Vui lòng kiểm tra email của bạn để đặt lại mật khẩu") { _ in
                        self?.back()
                    }
                }
            }
        }
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        isValidEmail = isValidEmailFormat(updatedText)
        updateContinueButtonState()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let email = textField.text {
            isValidEmail = isValidEmailFormat(email)
            updateContinueButtonState()
        }
    }
}

extension ForgotPasswordVC {
    @objc func hideKeyboardWhenTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
