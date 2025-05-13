//
//  RegisterVC.swift
//  MilkShopProject
//
//  Created by CongDev on 25/3/25.
//

import UIKit
//import FirebaseCore
//import FirebaseAuth
//import FirebaseFirestoreInternal
import Firebase


class RegisterVC: BaseViewController {

    //MARK: Outlets
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var reEnterPassTF: UITextField! {
        didSet {
            reEnterPassTF.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var passTF: UITextField! {
        didSet {
            passTF.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField! {
        didSet {
            phoneTF.keyboardType = .phonePad
        }
    }
    
    private var nameAccount = ""
    private var emailAccount = ""
    private var phoneAccount = ""
    private var passwordAccount = ""
    private var confirmPasswordAccount = ""
    private var role = ""
    private var address = [""]
    private var authen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTF()
        
        self.signupButton.isEnabled = false
        self.signupButton.alpha = 0.5
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        self.signIn()
    }
    
    private func setupTF() {
        phoneTF.delegate = self
        mailTF.delegate = self
        userTF.delegate = self
        passTF.delegate = self
        reEnterPassTF.delegate = self
    }
    
    private func signIn() {
        if isValidPassword(passwordAccount, confirmation: confirmPasswordAccount) {
                    Auth.auth().createUser(withEmail: emailAccount, password: passwordAccount) { result, error in
                        if let error = error {
                            // View Error
                            DispatchQueue.main.async {
                                let popUpView = PopUpErrorView(frame: self.view.frame)
                                self.view.addSubview(popUpView)
                                UIView.animate(withDuration: 0.3) {
                                    popUpView.titleLabel.text = "Lỗi Tạo Tài Khoản"
                                    popUpView.messageLabel.text = "Email đã được sử dụng.Vui lòng sử dụng email khác."
                                    popUpView.contentView.alpha = 1
                                    popUpView.blurView.alpha = 0.25
                                    popUpView.contentView.transform = .identity
                                }
                            }
                            print("[HL-LOG] Error - ", error.localizedDescription)
                        } else if let user = result?.user {
                            let uid = user.uid
                            
                            DispatchQueue.main.async {
                                let popUpView = PopUpSuccessSignUpView(frame: self.view.frame)
                                self.view.addSubview(popUpView)
                                UIView.animate(withDuration: 0.3) {
                                    popUpView.titleLabel.text = "Tạo tài khoản thành công"
                                    popUpView.messageLabel.text = "Tài khoản đã được tạo thành công. Hãy tận hưởng niềm vui của sản phẩm."
                                    popUpView.contentView.alpha = 1
                                    popUpView.blurView.alpha = 0.25
                                    popUpView.contentView.transform = .identity
                                }
                            }
                            let accountInfoData = AccountInfoModel(email: self.emailAccount, phone: self.phoneAccount, username: self.nameAccount, role: "false", address: [], password: self.passwordAccount, authcode: self.authen)
                            UDHelper.nameUser = self.nameAccount
                            UDHelper.phoneUser = self.phoneAccount
//                            UDHelper.roleUser = self.role
                            UDHelper.address = self.address
                            UDHelper.passWord = self.passwordAccount
                            UDHelper.authenCode = self.authen
                            UDHelper.email = self.emailAccount
                            FirestoreDatabaseManager.shared.writeAccountInfoDataToFirestore(account_info: accountInfoData)
                        }
                    }
                } else {
                    // View Error
                }
    }
    
    func handleDataTextField() {
        if !nameAccount.isEmpty && emailAccount.isValidEmail && !phoneAccount.isEmpty && isValidPassword(passwordAccount, confirmation: confirmPasswordAccount) {
            signupButton.isEnabled = true
            self.signupButton.alpha = 1
        } else {
            signupButton.isEnabled = false
            self.signupButton.alpha = 0.5
        }
        
        print("[HL-LOG] Email = \(emailAccount) - Password: \(passwordAccount) - ConfirmPassword: \(confirmPasswordAccount)")
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let userName = userTF.text, let email = mailTF.text, let phone = phoneTF.text, let password = passTF.text, let confirmPassword = reEnterPassTF.text else { return }
        
        nameAccount = userName
        emailAccount = email
        phoneAccount = phone
        passwordAccount = password
        confirmPasswordAccount = confirmPassword
        handleDataTextField()
    }
}

extension RegisterVC {
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
}
