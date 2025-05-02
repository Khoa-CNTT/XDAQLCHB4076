//
//  ProductsModel.swift
//  MilkShopProject
//
//  Created by CongDev on 8/4/25.
//

import Foundation

class Milks: Codable {
    var dataMilk: [DataMilk]?

    enum CodingKeys: String, CodingKey {
        case dataMilk
    }
}

class DataMilk: Codable {
    var idProduct: String?
    var type: String?
    var nameMilk: String?
    var imgMilk: String?
    var price: String?
    var detail: [Detail]?
    var priceInput: Int?
    var priceSell: Int?
    var quantity: Int?
    var totalImport: Int?
    var totalSell: Int?
    var sell: Int?

    enum CodingKeys: String, CodingKey {
        case idProduct, type, nameMilk, imgMilk, price, detail, priceInput, totalImport, priceSell, quantity, totalSell, sell
    }
}

class Detail: Codable {
    var trademark: String?
    var brandOrigin: String?
    var placeOfManufacture: String?
    var ingredient: String?
    var expiry: String?
    var userManual: String?
    var storageInstructions: String?
    var packaging: String?
    var description: String?
    var energy: String?
    var fat: String?
    var protein: String?
    var carbohydrates: String?
    var calcium: String?

    enum CodingKeys: String, CodingKey {
        case trademark, brandOrigin, placeOfManufacture, ingredient, expiry, userManual, storageInstructions, packaging, description, energy, fat, protein, carbohydrates, calcium
    }
}

func generateRandomID(type: String) -> String {
    let prefix = type
    let length = 10

    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString = ""

    for _ in 0..<length {
        if let randomChar = characters.randomElement() {
            randomString.append(randomChar)
        }
    }

    return prefix + randomString
}

