//
//  ProductsModel.swift
//  MilkShopProject
//
//  Created by CongDev on 8/4/25.
//

struct Milks: Codable {
    let dataMilk: [DataMilk]?
    
    enum CodingKeys: String, CodingKey {
        case dataMilk
    }
}

struct DataMilk: Codable {
    let type: String?
    let nameMilk: String?
    let imgMilk: String?
    let price: String?
    let detail: [Detail]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case nameMilk
        case imgMilk
        case price
        case detail
    }
}

struct Detail: Codable {
    let trademark: String?
    let brandOrigin: String?
    let placeOfManufacture: String?
    let ingredient: String?
    let expiry: String?
    let userManual: String?
    let storageInstructions: String?
    let packaging: String?
    let description: String?
    let energy: String?
    let fat: String?
    let protein: String?
    let carbohydrates: String?
    let calcium: String?
    
    enum CodingKeys: String, CodingKey {
        case trademark
        case brandOrigin
        case placeOfManufacture
        case ingredient
        case expiry
        case userManual
        case storageInstructions
        case packaging
        case description
        case energy
        case fat
        case protein
        case carbohydrates
        case calcium
    }
}
