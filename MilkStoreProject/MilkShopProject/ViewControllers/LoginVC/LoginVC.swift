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
    
    @IBAction func didTapForgotPwButton(_ sender: UIButton) {
        let vc = ForgotPasswordVC()
        self.push(vc)
    }
    
    private func setupTF() {
        self.passwordTF.isSecureTextEntry = true
        self.phoneNumberTF.delegate = self
        self.passwordTF.delegate = self
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
                if self.errorCount < 3 {
                    DispatchQueue.main.async {
                        let popUpView = PopUpErrorView(frame: self.view.frame)
                        self.view.addSubview(popUpView)
                        UIView.animate(withDuration: 0.3) {
                            popUpView.titleLabel.text = "Lỗi Đăng Nhập"
                            popUpView.messageLabel.text = "Thông tin Email hoặc Mật khẩu không chính xác. Vui lòng thử lại."
                            popUpView.contentView.alpha = 1
                            popUpView.blurView.alpha = 0.25
                            popUpView.contentView.transform = .identity
                        }
                    }
                    self.errorCount += 1
                    print("[HL-LOG] Đăng nhập thất bại: \(error.localizedDescription)")
                } else {
                    print("[HL-LOG] Vượt quá số lần thử")
                }
            } else {
                guard let phoneAccountInfo = self.phoneNumberTF.text else { return }
                UDHelper.phoneUser = phoneAccountInfo

                guard let uid = Auth.auth().currentUser?.uid else { return }

                FirestoreDatabaseManager.shared.getDocumentByID(collectionName: "usernew", documentID: uid) { document, error in
                    if let error = error {
                        print("[HL-LOG] Lỗi lấy dữ liệu người dùng: \(error.localizedDescription)")
                    } else if let document = document {
                        print("[HL-LOG] Tìm thấy document với ID: \(document.documentID)")

                        if let roleString = document.data()?["role"] as? String {
                            let role = (roleString.lowercased() == "true")
                            print("[HL-LOG] Role of user: \(role ? "Admin" : "User")")
                            UDHelper.roleUser = role
                        } else {
                            let role = document.data()?["role"] as? Bool ?? false
                            print("[HL-LOG] Role of user: \(role ? "Admin" : "User")")
                        }
                        
                        DispatchQueue.main.async {
                            let popUpView = PopUpSuccesssSignInVC(frame: self.view.frame)
                            self.view.addSubview(popUpView)

                            UIView.animate(withDuration: 0.3, animations: {
                                popUpView.contentView.alpha = 1
                                popUpView.blurView.alpha = 0.25
                                popUpView.contentView.transform = .identity
                            }) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    guard self.view.window != nil else {
                                        print("[HL-LOG] ViewController đã bị hủy.")
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        if let nav = self.navigationController {
                                            if nav.topViewController === self {
                                                AppDelegate.setRoot(TabbarCustomController(), isNavi: true)
                                                UDHelper.isLoginSuccess = true
                                                print("[HL-LOG] Chuyển sang màn hình chính - login success")
                                            } else {
                                                print("[HL-LOG] Không thể push - không ở top view controller")
                                            }
                                        } else {
                                            AppDelegate.setRoot(TabbarCustomController(), isNavi: true)
                                            UDHelper.isLoginSuccess = true
                                            print("[HL-LOG] Chuyển sang màn hình chính - login success (no nav)")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print("[HL-LOG] Không tìm thấy document cho UID: \(uid)")
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
