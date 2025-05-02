//
//  Untitled.swift
//  MilkShopProject
//
//  Created by CongDev on 29/4/25.
//

import RealmSwift

class DetailObject: Object {
    @Persisted var trademark: String?
    @Persisted var brandOrigin: String?
    @Persisted var placeOfManufacture: String?
    @Persisted var ingredient: String?
    @Persisted var expiry: String?
    @Persisted var userManual: String?
    @Persisted var storageInstructions: String?
    @Persisted var packaging: String?
    @Persisted var descriptionText: String?
    @Persisted var energy: String?
    @Persisted var fat: String?
    @Persisted var protein: String?
    @Persisted var carbohydrates: String?
    @Persisted var calcium: String?
}

class DataMilkObject: Object {
    @Persisted var idProduct: String?
    @Persisted var type: String?
    @Persisted var nameMilk: String?
    @Persisted var imgMilk: String?
    @Persisted var price: String?
    @Persisted var priceInput: Int?
    @Persisted var priceSell: Int?
    @Persisted var quantity: Int?
    @Persisted var totalImport: Int?
    @Persisted var totalSell: Int?
    @Persisted var sell: Int?
    @Persisted var detailList: List<DetailObject>
}

class MilksObject: Object {
    @Persisted var dataMilk = List<DataMilkObject>()
}
