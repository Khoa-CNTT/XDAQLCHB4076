//
//  ProductsModel.swift
//  MilkShopProject
//
//  Created by CongDev on 8/4/25.
//

import Foundation

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

func loadMilksFromJSON() -> Milks? {
    guard let path = Bundle.main.path(forResource: "Milk Data", ofType: "json") else {
        print("Không tìm thấy file JSON")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        let milksData = try decoder.decode(Milks.self, from: data)
        
        return milksData
    } catch {
        print("Lỗi khi đọc hoặc parse JSON: \(error)")
        return nil
    }
}
