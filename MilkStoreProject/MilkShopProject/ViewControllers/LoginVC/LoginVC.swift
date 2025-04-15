//
//  LoginVC.swift
//  MilkShopProject
//
//  Created by CongDev on 24/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class LoginVC: BaseViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTF: UITextField! {
        didSet {
            self.passwordTF.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var forgotPwButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var phoneAccount = ""
    private var passwordAccount = ""
    private var errorCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTF()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        handleDataTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        self.login()
    }
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        self.push(RegisterVC())
    }
    
    private func setupTF() {
        self.passwordTF.isSecureTextEntry = true
        self.phoneNumberTF.delegate = self
        self.passwordTF.delegate = self
    }
    
    private func signin(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { _, error in
            guard error == nil else { return }
            DispatchQueue.main.async {
                let popUpView = PopUpSuccesssSignInVC(frame: self.view.frame)
                self.view.addSubview(popUpView)
                UIView.animate(withDuration: 0.3) {
                    popUpView.contentView.alpha = 1
                    popUpView.blurView.alpha = 0.25
                    popUpView.contentView.transform = .identity
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.push(TabbarCustomController())
                #warning("need check")
                print("Push Tabbar")
            }
        }
    }
    
    func handleDataTextField() {
        if phoneAccount.isValidEmail && passwordAccount.isEmpty == false {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor(hexString: "083F78")
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(hexString: "083F78").withAlphaComponent(0.5)
        }
        print("[HL-LOG] Email = \(phoneAccount) - Password: \(passwordAccount)")
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

extension LoginVC {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            print("Bàn phím xuất hiện với chiều cao: \(keyboardHeight)")
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight / 2
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("Bàn phím ẩn")
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: phoneAccount, password: passwordAccount) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                // View Error
                if self.errorCount < 3 {
                    DispatchQueue.main.async {
                        let popUpView = PopUpErrorView(frame: self.view.frame)
                        self.view.addSubview(popUpView)
                        UIView.animate(withDuration: 0.3) {
                            popUpView.titleLabel.text = "Lỗi Đăng Nhập"
                            popUpView.messageLabel.text = "Thông tin Email hoặc Mật khẩu không chính xác.Vui lòng thử lại"
                            popUpView.contentView.alpha = 1
                            popUpView.blurView.alpha = 0.25
                            popUpView.contentView.transform = .identity
                        }
                    }
                    self.errorCount += 1
                    print("[HL-LOG] Error - ", error.localizedDescription)
                } else {
                    // Handle maximum error count
                    // You can uncomment and add your code here if necessary
                }
            } else {
                guard let phoneAccountInfo = self.phoneNumberTF.text else { return }
                UDHelper.phoneUser = phoneAccountInfo
                FirestoreDatabaseManager.shared.getDocumentByID(collectionName: "usernew", documentID: "\(UUID().uuidString)") { document, error in
                    if let error = error {
                        // Handle error
                        print("Error: \(error)")
                    } else if let document = document {
                        // Document exists
                        DispatchQueue.main.async {
                            let popUpView = PopUpSuccesssSignInVC(frame: self.view.frame)
                            self.view.addSubview(popUpView)
                            UIView.animate(withDuration: 0.3) {
                                popUpView.contentView.alpha = 1
                                popUpView.blurView.alpha = 0.25
                                popUpView.contentView.transform = .identity
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            #warning("need check")
                            self.push(TabbarCustomController())
                            UDHelper.isLoginSuccess = true
                            print("login success")
                        }
                    } else {
                        // Document does not exist
                        print("Document does not exist")
                    }
                }
            }
        }
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let phone = phoneNumberTF.text, let password = passwordTF.text else { return }
        phoneAccount = phone
        passwordAccount = password
        handleDataTextField()
    }
}
