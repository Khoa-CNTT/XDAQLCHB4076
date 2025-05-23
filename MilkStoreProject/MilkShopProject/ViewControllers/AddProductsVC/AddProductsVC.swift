//
//  AddProductsVC.swift
//  MilkShopProject
//
//  Created by CongDev on 14/5/25.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class AddProductsVC: BaseViewController {

    //MARK: Outlets
    @IBOutlet weak var storageInstructionsTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var imageProductLabel: UIImageView!
    @IBOutlet weak var energyTF: UITextField!
    @IBOutlet weak var descriptionDetailTF: UITextField!
    @IBOutlet weak var packagingTF: UITextField!
    @IBOutlet weak var userManualTF: UITextField!
    @IBOutlet weak var expiryTF: UITextField!
    @IBOutlet weak var ingredientTF: UITextField!
    @IBOutlet weak var placeOfManufactureTF: UITextField!
    @IBOutlet weak var brandOriginTF: UITextField!
    @IBOutlet weak var trademarkTF: UITextField!
    @IBOutlet weak var quantityTF: UITextField!
    @IBOutlet weak var priceInputTF: UITextField!
    @IBOutlet weak var priceSellTF: UITextField!
    @IBOutlet weak var typeProductTF: UITextField!
    @IBOutlet weak var nameProductTF: UITextField!
    
    //MARK: Properties
    private var selectedImage: UIImage?
    private var isLoading = false {
        didSet {
            addProductButton.isEnabled = !isLoading
            if isLoading {
                addProductButton.setTitle("Đang thêm...", for: .normal)
            } else {
                addProductButton.setTitle("Thêm sản phẩm", for: .normal)
            }
        }
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardHandling()
        setupTextFields()
        setupInitialState()
        setupTapGesture()
        setupImagePicker()
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTextFields() {
        let textFields = [nameProductTF, typeProductTF, priceSellTF, priceInputTF, 
                         quantityTF, brandOriginTF, trademarkTF, placeOfManufactureTF,
                         ingredientTF, expiryTF, userManualTF, packagingTF, descriptionDetailTF,
                          energyTF, storageInstructionsTF]
        
        textFields.forEach { textField in
            textField?.delegate = self
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupInitialState() {
        addProductButton.isEnabled = false
        addProductButton.setTitle("Thêm sản phẩm", for: .normal)
        
        [nameProductTF, typeProductTF, priceSellTF, priceInputTF, 
         quantityTF, brandOriginTF, trademarkTF, placeOfManufactureTF,
         ingredientTF, expiryTF, userManualTF, packagingTF, descriptionDetailTF,
         energyTF, storageInstructionsTF].forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupImagePicker() {
        onImagePicked = { [weak self] image in
            self?.selectedImage = image
            self?.imageProductLabel.image = image
            self?.addProductButton.isEnabled = true
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if let activeTextField = findActiveTextField() {
            let rect = activeTextField.convert(activeTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func findActiveTextField() -> UITextField? {
        let textFields = [nameProductTF, typeProductTF, priceSellTF, priceInputTF, 
                         quantityTF, brandOriginTF, trademarkTF, placeOfManufactureTF,
                         ingredientTF, expiryTF, userManualTF, packagingTF, descriptionDetailTF,
                          energyTF, storageInstructionsTF]
        return textFields.first { $0?.isFirstResponder == true } ?? nameProductTF
    }
    
    @objc private func handleTapGesture() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        addProductButton.isEnabled = validateInputs()
    }
    
    private func validateInputs() -> Bool {
        guard let name = nameProductTF.text, !name.isEmpty,
              let type = typeProductTF.text, !type.isEmpty,
              let priceSell = priceSellTF.text, !priceSell.isEmpty,
              let priceInput = priceInputTF.text, !priceInput.isEmpty,
              let quantity = quantityTF.text, !quantity.isEmpty,
              let brandOrigin = brandOriginTF.text, !brandOrigin.isEmpty,
              let trademark = trademarkTF.text, !trademark.isEmpty,
              let placeOfManufacture = placeOfManufactureTF.text, !placeOfManufacture.isEmpty,
              let ingredient = ingredientTF.text, !ingredient.isEmpty,
              let expiry = expiryTF.text, !expiry.isEmpty,
              let userManual = userManualTF.text, !userManual.isEmpty,
              let packaging = packagingTF.text, !packaging.isEmpty,
              let descriptionDetail = descriptionDetailTF.text, !descriptionDetail.isEmpty,
              let energy = energyTF.text, !energy.isEmpty,
              let storageInstruct = storageInstructionsTF.text, !storageInstruct.isEmpty,
              selectedImage != nil else {
            return false
        }
        return true
    }
    
    @IBAction func didTapChoosePhotoButton(_ sender: UIButton) {
        view.endEditing(true)
        checkPhotoPermission()
    }
    
    @IBAction func didTapAddButton(_ sender: UIButton) {
        guard !isLoading else { return }
        
        guard let name = nameProductTF.text, !name.isEmpty,
              let type = typeProductTF.text, !type.isEmpty,
              let priceSell = priceSellTF.text, !priceSell.isEmpty,
              let priceInput = priceInputTF.text, !priceInput.isEmpty,
              let quantity = quantityTF.text, !quantity.isEmpty,
              let brandOrigin = brandOriginTF.text, !brandOrigin.isEmpty,
              let trademark = trademarkTF.text, !trademark.isEmpty,
              let placeOfManufacture = placeOfManufactureTF.text, !placeOfManufacture.isEmpty,
              let ingredient = ingredientTF.text, !ingredient.isEmpty,
              let expiry = expiryTF.text, !expiry.isEmpty,
              let userManual = userManualTF.text, !userManual.isEmpty,
              let packaging = packagingTF.text, !packaging.isEmpty,
              let descriptionDetail = descriptionDetailTF.text, !descriptionDetail.isEmpty,
              let energy = energyTF.text, !energy.isEmpty,
              let storageInstruct = storageInstructionsTF.text, !storageInstruct.isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng điền đầy đủ thông tin")
            return
        }
        
        isLoading = true
        
        FirebaseUploader.shared.uploadProductImage(selectedImage ?? UIImage(), currentImageUrl: nil) { [weak self] imageURL in
            guard let self = self else { return }
            
            if let imageURL = imageURL {
                self.addProductWithImageURL(imageURL: imageURL)
            } else {
                self.isLoading = false
                self.showAlert(title: "Lỗi", message: "Không thể xử lý ảnh")
            }
        }
    }
    
    private func addProductWithImageURL(imageURL: String) {
        guard let name = nameProductTF.text,
              let type = typeProductTF.text,
              let priceSell = priceSellTF.text,
              let priceInput = priceInputTF.text,
              let quantity = quantityTF.text,
              let brandOrigin = brandOriginTF.text,
              let trademark = trademarkTF.text,
              let placeOfManufacture = placeOfManufactureTF.text,
              let ingredient = ingredientTF.text,
              let expiry = expiryTF.text,
              let userManual = userManualTF.text,
              let packaging = packagingTF.text,
              let descriptionDetail = descriptionDetailTF.text,
              let energy = energyTF.text,
              let storageInstruct = storageInstructionsTF.text else {
            isLoading = false
            return
        }
        
        print("🔍 Type từ textfield: \(type)")
        
        let energyText = "\(energy) kcal"
        let productData: [String: Any] = [
            "nameMilk": name,
            "type": type,
            "price": "\(formatCurrency(Double(priceSell) ?? 0)) đ",
            "priceSell": Int(priceSell) ?? 0,
            "priceInput": Int(priceInput) ?? 0,
            "quantity": Int(quantity) ?? 0,
            "imgMilk": imageURL,
            "detailList": [[
                "brandOrigin": brandOrigin,
                "trademark": trademark,
                "placeOfManufacture": placeOfManufacture,
                "ingredient": ingredient,
                "expiry": expiry,
                "userManual": userManual,
                "packaging": packaging,
                "description": descriptionDetail,
                "energy": energyText,
                "storageInstructions": storageInstruct
            ]]
        ]
        
        print("📦 Product Data trước khi gọi addProduct: \(productData)")
        
        FirebaseUploader.shared.addProduct(type: type, productData: productData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.showAlert(title: "Lỗi", message: "Không thể thêm sản phẩm: \(error.localizedDescription)")
            } else {
                self.addProductToRealm(productData: productData)
            }
        }
    }
    
    private func addProductToRealm(productData: [String: Any]) {
        let product = DataMilkObject()
        product.idProduct = productData["idProduct"] as? String
        product.nameMilk = productData["nameMilk"] as? String ?? ""
        product.type = productData["type"] as? String ?? ""
        product.price = productData["price"] as? String ?? ""
        product.priceSell = productData["priceSell"] as? Int ?? 0
        product.priceInput = productData["priceInput"] as? Int ?? 0
        product.quantity = productData["quantity"] as? Int ?? 0
        product.imgMilk = productData["imgMilk"] as? String ?? ""
        
        if let detailList = productData["detailList"] as? [[String: Any]],
           let firstDetail = detailList.first {
            let detail = DetailObject()
            detail.brandOrigin = firstDetail["brandOrigin"] as? String ?? ""
            detail.trademark = firstDetail["trademark"] as? String ?? ""
            detail.placeOfManufacture = firstDetail["placeOfManufacture"] as? String ?? ""
            detail.ingredient = firstDetail["ingredient"] as? String ?? ""
            detail.expiry = firstDetail["expiry"] as? String ?? ""
            detail.userManual = firstDetail["userManual"] as? String ?? ""
            detail.packaging = firstDetail["packaging"] as? String ?? ""
            detail.descriptionText = firstDetail["description"] as? String ?? ""
            detail.energy = firstDetail["energy"] as? String ?? ""
            detail.storageInstructions = firstDetail["storageInstructions"] as? String ?? ""
            product.detailList.append(detail)
        }
        
        try? RealmManager.shared.realm.write {
            RealmManager.shared.realm.add(product)
        }
        
        self.isLoading = false
        self.showAlert(title: "Thành công", message: "Thêm sản phẩm thành công") { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
}

// MARK: - UITextFieldDelegate
extension AddProductsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let activeTextField = findActiveTextField() {
            let rect = activeTextField.convert(activeTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
}
