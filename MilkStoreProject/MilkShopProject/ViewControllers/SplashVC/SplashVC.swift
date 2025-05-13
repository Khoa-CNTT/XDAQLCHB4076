//
//  SplashVC.swift
//  MilkShopProject
//
//  Created by CongDev on 24/3/25.
//

import UIKit
import FirebaseFirestore
import Lottie
import FirebaseAuth

class SplashVC: BaseViewController {
    
    
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isFirstLaunch() {
            self.fetchData()
        } else {
            moveToNextScreen()
        }
        
        self.configureAnimation(loadingAnimationView, "loadingSplash", isPlay: true)
//        let uploader = FirebaseUploader()
//        uploader.readAndUploadProducts(from: "Milk Data")
    }
    
    private func fetchData() {
        FirebaseDataFetcher.shared.fetchAllMilks { milks, error in
            if let error = error {
                print("Lỗi khi fetch dữ liệu: \(error.localizedDescription)")
                return
            }
            guard let milks = milks else {
                print("Lỗi hoặc không có dữ liệu")
                return
            }
            
            let dataMilks = milks.dataMilk ?? []
            let dataMilkObject = dataMilks.map {  self.convertToDataMilkObject(from: $0) }
            RealmManager.shared.addMilkObj(object: dataMilkObject)
            self.moveToNextScreen()
        }
    }
    
    private func moveToNextScreen() {
        let nextVC: UIViewController
        if UDHelper.isLoginSuccess {
            nextVC = TabbarCustomController()
        } else {
            nextVC = LoginVC()
        }

        if !(nextVC is UINavigationController) {
            AppDelegate.setRoot(nextVC, isNavi: true)
        } else {
            AppDelegate.setRoot(nextVC, isNavi: false)
        }
        
        self.loadingAnimationView.stop()
    }
    
    private func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if hasLaunchedBefore {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
    }
    
    func convertToDataMilkObject(from dataMilk: DataMilk) -> DataMilkObject {
        let object = DataMilkObject()
        object.idProduct = dataMilk.idProduct
        object.type = dataMilk.type
        object.nameMilk = dataMilk.nameMilk
        object.imgMilk = dataMilk.imgMilk
        object.price = dataMilk.price
        object.priceInput = dataMilk.priceInput ?? 0
        object.priceSell = dataMilk.priceSell ?? 0
        object.quantity = dataMilk.quantity ?? 0
        object.totalImport = dataMilk.totalImport ?? 0
        object.totalSell = dataMilk.totalSell ?? 0
        object.sell = dataMilk.sell ?? 0

        if let details = dataMilk.detail {
            for detail in details {
                let detailObj = DetailObject()
                detailObj.trademark = detail.trademark
                detailObj.brandOrigin = detail.brandOrigin
                detailObj.placeOfManufacture = detail.placeOfManufacture
                detailObj.ingredient = detail.ingredient
                detailObj.expiry = detail.expiry
                detailObj.userManual = detail.userManual
                detailObj.storageInstructions = detail.storageInstructions
                detailObj.packaging = detail.packaging
                detailObj.descriptionText = detail.description
                detailObj.energy = detail.energy
                detailObj.fat = detail.fat
                detailObj.protein = detail.protein
                detailObj.carbohydrates = detail.carbohydrates
                detailObj.calcium = detail.calcium
                object.detailList.append(detailObj)
            }
        }

        return object
    }
}
