//
//  EditProductVC.swift
//  MilkShopProject
//
//  Created by CongDev on 14/5/25.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class EditProductVC: BaseViewController {

    //MARK: Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var updateProductButton: UIButton!
    @IBOutlet weak var imageProductLabel: UIImageView!
    @IBOutlet weak var nameProductTF: UITextField!
    @IBOutlet weak var typeProductTF: UITextField!
    @IBOutlet weak var priceSellProductTF: UITextField!
    @IBOutlet weak var priceInputProductTF: UITextField!
    @IBOutlet weak var quantityInputProductTF: UITextField!
    @IBOutlet weak var brandOriginProductTF: UITextField!
    @IBOutlet weak var expProductTF: UITextField!
    
    //MARK: Properties
    
    var product: DataMilkObject?
    private var selectedImage: UIImage?
    private var isLoading = false {
        didSet {
            updateProductButton.isEnabled = !isLoading
            if isLoading {
                updateProductButton.setTitle("Đang cập nhật...", for: .normal)
            } else {
                updateProductButton.setTitle("Cập nhật", for: .normal)
            }
        }
    }
    
    private var hasChanges: Bool {
        guard let product = product else { return false }
        
        let nameChanged = nameProductTF.text != product.nameMilk
        let typeChanged = typeProductTF.text != product.type
        let priceSellChanged = priceSellProductTF.text != product.price
        let priceInputChanged = priceInputProductTF.text != "\(product.priceInput ?? 0)"
        let quantityChanged = quantityInputProductTF.text != "\(product.quantity ?? 0)"
        let brandOriginChanged = brandOriginProductTF.text != product.detailList.first?.brandOrigin
        let expChanged = expProductTF.text != product.detailList.first?.expiry
        let imageChanged = selectedImage != nil
        
        return nameChanged || typeChanged || priceSellChanged || priceInputChanged || 
               quantityChanged || brandOriginChanged || expChanged || imageChanged
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
    
    override func setupUI() {
        guard let product = product,
              let price = product.price,
              let priceInput = product.priceInput,
              let convertPriceSellToInt = convertPriceToInt(price),
              let quantity = product.quantity,
              let detailList = product.detailList.first
        else { return }
        
        if let imgMilk = product.imgMilk, imgMilk.hasPrefix("data:image") {
            imageProductLabel.loadBase64Image(imgMilk)
        } else if let imgMilk = product.imgMilk {
            let url = URL(string: imgMilk)
            self.imageProductLabel.kf.setImage(with: url)
        }
        
        nameProductTF.text = product.nameMilk
        typeProductTF.text = product.type
        priceSellProductTF.text = "\(convertPriceSellToInt)"
        priceInputProductTF.text = "\(priceInput)"
        quantityInputProductTF.text = "\(quantity)"
        brandOriginProductTF.text = detailList.brandOrigin
        expProductTF.text = detailList.expiry
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTextFields() {
        let textFields = [nameProductTF, typeProductTF, priceSellProductTF, priceInputProductTF, 
                         quantityInputProductTF, brandOriginProductTF, expProductTF]
        
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
        updateProductButton.isEnabled = false
        updateProductButton.setTitle("Cập nhật", for: .normal)
        
        // Thêm observer cho các textfield
        [nameProductTF, typeProductTF, priceSellProductTF, priceInputProductTF, 
         quantityInputProductTF, brandOriginProductTF, expProductTF].forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupImagePicker() {
        onImagePicked = { [weak self] image in
            self?.selectedImage = image
            self?.imageProductLabel.image = image
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
        let textFields = [nameProductTF, typeProductTF, priceSellProductTF, priceInputProductTF, 
                         quantityInputProductTF, brandOriginProductTF, expProductTF]
        return textFields.first { $0?.isFirstResponder == true } ?? nameProductTF
    }
    
    @objc private func handleTapGesture() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        updateProductButton.isEnabled = hasChanges
    }
    
    @IBAction func didTapChoosePhotoButton(_ sender: UIButton) {
        view.endEditing(true)
        checkPhotoPermission()
    }
    
    @IBAction func didTapUpdateButton(_ sender: UIButton) {
        guard !isLoading else { return }
        
        guard let name = nameProductTF.text, !name.isEmpty,
              let type = typeProductTF.text, !type.isEmpty,
              let priceSell = priceSellProductTF.text, !priceSell.isEmpty,
              let priceInput = priceInputProductTF.text, !priceInput.isEmpty,
              let quantity = quantityInputProductTF.text, !quantity.isEmpty,
              let brandOrigin = brandOriginProductTF.text, !brandOrigin.isEmpty,
              let exp = expProductTF.text, !exp.isEmpty,
              let product = product else {
            showAlert(title: "Lỗi", message: "Vui lòng điền đầy đủ thông tin")
            return
        }
        
        isLoading = true
        
        if let selectedImage = selectedImage {
            FirebaseUploader.shared.uploadProductImage(selectedImage, currentImageUrl: product.imgMilk) { [weak self] imageURL in
                guard let self = self else { return }
                
                if let imageURL = imageURL {
                    self.updateProductWithImageURL(imageURL: imageURL, product: product)
                } else {
                    self.isLoading = false
                    self.showAlert(title: "Lỗi", message: "Không thể xử lý ảnh")
                }
            }
        } else {
            updateProductWithImageURL(imageURL: product.imgMilk ?? "", product: product)
        }
    }
    
    private func updateProductWithImageURL(imageURL: String, product: DataMilkObject) {
        guard let name = nameProductTF.text,
              let type = typeProductTF.text,
              let priceSell = priceSellProductTF.text,
              let priceInput = priceInputProductTF.text,
              let quantity = quantityInputProductTF.text,
              let brandOrigin = brandOriginProductTF.text,
              let exp = expProductTF.text else {
            isLoading = false
            return
        }
        
        FirebaseUploader.shared.updateProduct(
            productId: product.idProduct ?? "",
            name: name,
            type: type,
            priceSell: priceSell,
            priceInput: priceInput,
            quantity: quantity,
            brandOrigin: brandOrigin,
            exp: exp,
            imageURL: imageURL
        ) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.showAlert(title: "Lỗi", message: "Không thể cập nhật sản phẩm: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Thành Công", message: "Cập nhật sản phẩm thành công")
                self.updateProductInRealm(
                    product: product,
                    name: name,
                    type: type,
                    priceSell: priceSell,
                    priceInput: Int(priceInput) ?? 0,
                    quantity: Int(quantity) ?? 0,
                    brandOrigin: brandOrigin,
                    exp: exp,
                    imageURL: imageURL,
                    price: "\(self.formatCurrency(Double(priceSell) ?? 0)) đ"
                )
            }
        }
    }
    
    private func updateProductInRealm(
        product: DataMilkObject,
        name: String,
        type: String,
        priceSell: String,
        priceInput: Int,
        quantity: Int,
        brandOrigin: String,
        exp: String,
        imageURL: String,
        price: String
    ) {
        try? RealmManager.shared.realm.write {
            product.nameMilk = name
            product.type = type
            product.price = price
            product.priceSell = Int(priceSell)
            product.priceInput = priceInput
            product.quantity = quantity
            product.imgMilk = imageURL
            
            if let detail = product.detailList.first {
                detail.brandOrigin = brandOrigin
                detail.expiry = exp
            }
        }
        
        self.isLoading = false
        self.showAlert(title: "Thành công", message: "Cập nhật sản phẩm thành công") { [weak self] _ in
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
extension EditProductVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let activeTextField = findActiveTextField() {
            let rect = activeTextField.convert(activeTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
}
