//
//  AddAddressVC.swift
//  MilkShopProject
//
//  Created by CongDev on 6/5/25.
//

import UIKit
import FirebaseAuth



class AddAddressVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var nameUserView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var wardView: UIView!
    @IBOutlet weak var districtView: UIView!
    @IBOutlet weak var provinceView: UIView!
    @IBOutlet weak var phoneUserErrorLabel: UILabel!
    @IBOutlet weak var nameUserErrorLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var wardErrorLabel: UILabel!
    @IBOutlet weak var districtErrorLabel: UILabel!
    @IBOutlet weak var provinceErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var nameUserTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var wardTF: UITextField!
    @IBOutlet weak var districtTF: UITextField!
    @IBOutlet weak var provinceTF: UITextField!
    
    var allProvinces: [Province] = []
    var selectedProvince: Province?
    var selectedDistrict: District?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAddressData()
        
        let errorLabel = [
            phoneUserErrorLabel,
            nameUserErrorLabel,
            addressErrorLabel,
            wardErrorLabel,
            districtErrorLabel,
            provinceErrorLabel
        ]
        
        errorLabel.forEach { $0?.isHidden = true }
        self.nameUserTF.delegate = self
        self.addressTF.delegate = self
        self.phoneNumberTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupKeyboardNotifications()
        hideKeyboardWhenTappedAround()
    }
    
    func loadAddressData() {
        guard let url = Bundle.main.url(forResource: "address", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let wrapper = try JSONDecoder().decode(AddressWrapper.self, from: data)
            allProvinces = wrapper.data
        } catch {
            print("Lỗi khi đọc JSON: \(error)")
        }
    }
    
    @IBAction func didTapSelectProvince(_ sender: Any) {
        let vc = ProvinceBottomSheetVC()
        vc.items = allProvinces.map { $0.name }
        vc.selectionType = .province
        vc.selectedItem = selectedProvince?.name
        vc.onSelect = { [weak self] selected in
            guard let self else { return }
            
            if selectedProvince?.name != selected {
                self.districtTF.text = "Chọn Quận/ Huyện"
                self.wardTF.text = "Chọn Phường/ Xã"
            }
            self.provinceTF.text = selected
            self.selectedProvince = self.allProvinces.first { $0.name == selected }
            self.hideError(label: provinceErrorLabel, view: provinceView)
        }
        self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 32)
    }
    
    @IBAction func didTapSelectDistrict(_ sender: Any) {
        guard let selectedProvince else {
            showToast(message: "Vui lòng chọn Tỉnh/Thành trước")
            return
        }
        let vc = ProvinceBottomSheetVC()
        vc.items = selectedProvince.districts.map { $0.name }
        vc.selectionType = .district
        vc.selectedItem = selectedDistrict?.name
        vc.onSelect = { [weak self] selected in
            guard let self else { return }
            self.districtTF.text = selected
            self.selectedDistrict = self.selectedProvince?.districts.first { $0.name == selected }
            self.hideError(label: districtErrorLabel, view: districtView)
        }
        self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 32)
    }
    
    @IBAction func didTapAddAddressButton(_ sender: Any) {
        var isValid = true
        
        if provinceTF.text?.isEmpty ?? true {
            showError(label: provinceErrorLabel, message: "Nhập Tỉnh/ Thành phố", view: provinceView)
            isValid = false
        } else {
            hideError(label: provinceErrorLabel, view: provinceView)
        }
        
        if districtTF.text?.isEmpty ?? true {
            showError(label: districtErrorLabel, message: "Nhập Quận/ Huyện", view: districtView)
            isValid = false
        } else {
            hideError(label: districtErrorLabel, view: districtView)
        }
        
        if wardTF.text?.isEmpty ?? true {
            showError(label: wardErrorLabel, message: "Vui lòng chọn Phường/ Xã", view: wardView)
            isValid = false
        } else {
            hideError(label: wardErrorLabel, view: wardView)
        }
        
        if addressTF.text?.isEmpty ?? true {
            showError(label: addressErrorLabel, message: "Vui lòng điền Địa chỉ", view: addressView)
            isValid = false
        } else {
            hideError(label: addressErrorLabel, view: addressView)
        }
        
        if nameUserTF.text?.isEmpty ?? true {
            showError(label: nameUserErrorLabel, message: "Vui lòng điền Họ và tên đệm", view: nameUserView)
            isValid = false
        } else {
            hideError(label: nameUserErrorLabel, view: nameUserView)
        }
        
        if phoneNumberTF.text?.isEmpty ?? true {
            showError(label: phoneUserErrorLabel, message: "Vui lòng điền Tên", view: phoneNumberView)
            isValid = false
        } else {
            hideError(label: phoneUserErrorLabel, view: phoneNumberView)
        }
        
        if !isValid { return }
        
        guard let province = provinceTF.text, !province.isEmpty,
              let district = districtTF.text, !district.isEmpty,
              let ward = wardTF.text, !ward.isEmpty,
              let address = addressTF.text, !address.isEmpty,
              let name = nameUserTF.text, !name.isEmpty,
              let numberPhone = phoneNumberTF.text, !numberPhone.isEmpty
        else {
            return
        }
            
        let newAddress = "\(province), \(district), \(ward), \(address), \(name), \(numberPhone)"
        
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseDataFetcher().updateUserAddress(uid: uid, newAddress: newAddress)
        }
        
        self.showToast(message: "Địa chỉ đã được cập nhật thành công.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss()
        }
        
    }
    
    @IBAction func didTapSelectWard(_ sender: Any) {
        guard let selectedDistrict else {
            showToast(message: "Vui lòng chọn Quận/Huyện trước")
            return
        }
        let vc = ProvinceBottomSheetVC()
        vc.items = selectedDistrict.wards
        vc.selectionType = .ward
        vc.selectedItem = selectedDistrict.wards.first { $0 == wardTF.text ?? ""}
        vc.onSelect = { [weak self] selected in
            guard let self = self else { return }
            self.wardTF.text = selected
            self.hideError(label: self.wardErrorLabel!, view: self.wardView!)
        }
        self.openBottomSheet(vc: vc, ratioView: 0.5, corner: 32)
    }
    @IBAction func didTapBackButton(_ sender: Any) {
        self.dismiss()
    }
}

extension AddAddressVC {
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardTopY = self.view.frame.height - keyboardFrame.height
        if let activeField = self.view.currentFirstResponder() as? UIView {
            let fieldFrame = activeField.convert(activeField.bounds, to: self.view)
            let fieldBottomY = fieldFrame.origin.y + fieldFrame.height
            
            if fieldBottomY > keyboardTopY {
                let overlap = fieldBottomY - keyboardTopY + 20 
                self.view.frame.origin.y = CGFloat(-overlap)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showError(label: UILabel, message: String, view: UIView) {
        label.text = message
        label.isHidden = false
        view.layer.borderColor = UIColor.red.cgColor
    }

    func hideError(label: UILabel, view: UIView) {
        label.isHidden = true
        view.layer.borderColor = UIColor(hexString: "163C75").cgColor
    }
}

extension AddAddressVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = self.addressTF.text {
            if text.isEmpty {
                showError(label: addressErrorLabel, message: "Vui lòng điền Địa chỉ", view: addressView)
            } else {
                hideError(label: addressErrorLabel, view: addressView)
            }
        }
        
        if let text = self.nameUserTF.text {
            if text.isEmpty {
                showError(label: nameUserErrorLabel, message: "Vui lòng điền Họ và tên đệm", view: nameUserView)
            } else {
                hideError(label: nameUserErrorLabel, view: nameUserView)
            }
        }
        
        if let text = self.phoneNumberTF.text {
            if text.isEmpty {
                showError(label: phoneUserErrorLabel, message: "Vui lòng điền Họ và tên đệm", view: phoneNumberView)
            } else {
                hideError(label: phoneUserErrorLabel, view: phoneNumberView)
            }
        }
        return true
    }
}
