//
//  DetailProductsVC.swift
//  MilkShopProject
//
//  Created by CongDev on 16/4/25.
//

import UIKit
import Kingfisher

class DetailProductsVC: BaseViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var countProductTF: UITextField!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var ctnTopNotiAddProductSuccessView: NSLayoutConstraint!
    @IBOutlet weak var ctnHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var calciumLabel: UILabel!
    @IBOutlet weak var calciumView: UIView!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var fatView: UIView!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var proteinView: UIView!
    @IBOutlet weak var hydratLabel: UILabel!
    @IBOutlet weak var hydratCacbonView: UIView!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var energyView: UIView!
    @IBOutlet weak var detailsProductLabel: UILabel!
    @IBOutlet weak var minusNumberButton: UIButton!
    @IBOutlet weak var priceProductLabel: UILabel!
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var infoProductTableView: UITableView!
    
    var timer:Timer?
    private var isDialogVisible = false
    private var countProduct: Int = 1
    
    //MARK: Init
    init(dataMilk: DataMilkObject){
        super.init(nibName: nil, bundle: nil)
        
        self.dataMilk = dataMilk
        print("dataMilk: \(dataMilk.idProduct ?? "")")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    
    private var dataMilk: DataMilkObject?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.ctnHeightTableView.constant = self.infoProductTableView.contentSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    override func setupUI() {
        self.setUpTableView(self.infoProductTableView, ProductInfoTableCell.self)
        self.handleUI()
        self.countProductTF.keyboardType = .numberPad
        addDoneButtonOnKeyboard(textField: self.countProductTF)
    }
    
    //MARK: Actions
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.back()
    }
    
    @IBAction func didTapMinusNumberButton(_ sender: UIButton) {
        self.minusNumberButton.isEnabled = self.countProductTF.text != "1"
        self.countProduct -= 1
        self.countProductTF.text = "\(self.countProduct)"
    }
    
    @IBAction func didTapPlusNumberButton(_ sender: UIButton) {
        self.countProduct += 1
        if self.countProduct >= 1 {
            self.minusNumberButton.isEnabled = true
        }
        self.countProductTF.text = "\(self.countProduct)"
        if let dataMilk = dataMilk,
           let totalImport = dataMilk.totalImport {
            if self.countProduct > totalImport {
                showAlert(title: "Số lượng vượt quá",
                          message: "Số lượng bạn muốn mua lớn hơn số lượng hiện có trong cửa hàng. Vui lòng điều chỉnh lại.")
            }
        }
    }
    
    @IBAction func didTapAddCartButton(_ sender: UIButton) {
        
        if let dataMilk = dataMilk {
            if self.countProduct == 0 {
                self.showAlert(title: "Số lượng không hợp lệ",
                               message: "Vui lòng nhập số lượng lớn hơn 0 để thêm sản phẩm vào giỏ hàng.")
                self.minusNumberButton.isEnabled = false
                self.countProductTF.text = "1"
            } else {
                if let idProduct = dataMilk.idProduct {
                    CartService.share.addProduct(productId: idProduct,
                                                 quantity: self.countProduct)
                }
                self.showDialogCopy()
            }
        }
    }
    
    @IBAction func didTapBuyProductButton(_ sender: Any) {
        self.push(CartVC())
    }
    
    //MARK: Handle func
    func addDoneButtonOnKeyboard(textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
        
        if let numberText = self.countProductTF.text,
           let count = Int(numberText),
           let dataMilk = dataMilk,
           let totalImport = dataMilk.totalImport {
            if count > totalImport {
                showAlert(title: "Số lượng vượt quá",
                          message: "Số lượng bạn muốn mua lớn hơn số lượng hiện có trong cửa hàng. Vui lòng điều chỉnh lại.")
            } else {
                self.countProduct = count
            }
        }
        print("count:\(self.countProduct)")
    }
    
    private func handleUI() {
        guard let dataMilk = dataMilk,
              let firstDetail = dataMilk.detailList.first,
              let nameProduct = dataMilk.nameMilk,
              let imageProduct = dataMilk.imgMilk,
              let descText = firstDetail.descriptionText
        else { return }
        
        self.productImageView.kf.indicatorType = .activity
        let url = URL(string: imageProduct)
        self.productImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.3))
            ]
        )
        self.nameProductLabel.text = nameProduct.uppercased()
        self.priceProductLabel.text = dataMilk.price
        
        let formatted = formattedDescription(from: descText)
        
        print("formatted: \(formatted)")
        self.detailsProductLabel.text = formatted
        
        self.fatView.isHidden = isHidden(firstDetail.fat)
        self.energyView.isHidden = isHidden(firstDetail.energy)
        self.calciumView.isHidden = isHidden(firstDetail.calcium)
        self.hydratCacbonView.isHidden = isHidden(firstDetail.carbohydrates)
        self.proteinView.isHidden = isHidden(firstDetail.protein)
        self.fatLabel.text = "\(firstDetail.fat ?? "0") g"
        self.energyLabel.text = "\(firstDetail.energy ?? "0") kcal"
        self.calciumLabel.text = "\(firstDetail.calcium ?? "0") mg"
        self.hydratLabel.text =  "\(firstDetail.carbohydrates ?? "0") g"
        self.proteinLabel.text = "\(firstDetail.protein ?? "0") g"
    }
    
}

extension DetailProductsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataMilk = dataMilk, !dataMilk.detailList.isEmpty else {
            return 0
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ProductInfoTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        guard let dataMilk = dataMilk else { return UITableViewCell() }
        let detail = dataMilk.detailList
        
        switch indexPath.row {
        case 0:
            cell.productLabel.text = "Thương hiệu".uppercased()
            cell.productPropertyLabel.text = detail[0].trademark
        case 1:
            cell.productLabel.text = "Xuất xứ thương hiệu".uppercased()
            cell.productPropertyLabel.text = detail[0].brandOrigin
        case 2:
            cell.productLabel.text = "Nơi sản xuất".uppercased()
            cell.productPropertyLabel.text = detail[0].placeOfManufacture
        case 3:
            cell.productLabel.text = "Thành phần".uppercased()
            cell.productPropertyLabel.text = detail[0].ingredient
        case 4:
            cell.productLabel.text = "Hạn sử dụng".uppercased()
            cell.productPropertyLabel.text = detail[0].expiry
        case 5:
            cell.productLabel.text = "Hướng dẫn sử dụng".uppercased()
            cell.productPropertyLabel.text = detail[0].userManual
        case 6:
            cell.productLabel.text = "Hướng dẫn bảo quản".uppercased()
            cell.productPropertyLabel.text = detail[0].storageInstructions
        default:
            cell.productLabel.text = "Quy cách đóng gói".uppercased()
            cell.productPropertyLabel.text = detail[0].packaging
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension DetailProductsVC {
    func isHidden(_ value: String?) -> Bool {
        return value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    
    func showDialogCopy() {
        guard !isDialogVisible else { return }
        isDialogVisible = true
        addProductButton.isEnabled = false
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.ctnTopNotiAddProductSuccessView.constant = 20
            self.view.layoutIfNeeded()
        })
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(hideDialogCopy),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc func hideDialogCopy(){
        timer?.invalidate()
        timer = nil
        isDialogVisible = false
        addProductButton.isEnabled = true
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.ctnTopNotiAddProductSuccessView.constant = -300
            self.view.layoutIfNeeded()
        })
    }
}
