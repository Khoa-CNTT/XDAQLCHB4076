//
//  AddressModel.swift
//  MilkShopProject
//
//  Created by CongDev on 7/5/25.
//
import Foundation

struct AddressWrapper: Decodable {
    let data: [Province]

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

struct Province: Decodable {
    let name: String
    let districts: [District]

    enum CodingKeys: String, CodingKey {
        case name = "TinhThanhPho"
        case districts = "QuanHuyenDS"
    }
}

struct District: Decodable {
    let name: String
    let wards: [String]

    enum CodingKeys: String, CodingKey {
        case nameFallback1 = "QuanHuyen"
        case nameFallback2 = "ThanhPho"
        case wards = "PhuongXaDS"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wards = try container.decode([String].self, forKey: .wards)

        if let name = try? container.decode(String.self, forKey: .nameFallback1) {
            self.name = name
        } else if let name = try? container.decode(String.self, forKey: .nameFallback2) {
            self.name = name
        } else {
            throw DecodingError.keyNotFound(CodingKeys.nameFallback1,
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Missing both QuanHuyen and ThanhPho"))
        }
    }
}
