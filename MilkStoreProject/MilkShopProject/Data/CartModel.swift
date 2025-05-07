//
//  CartObject.swift
//  MilkShopProject
//
//  Created by CongDev on 30/4/25.
//

import RealmSwift

struct CartModel {
    var idProduct: String
    var idUser: String
    var nameProduct: String
    var imageProduct: String
    var price: String
    var quantity: Int
    var isSelected: Bool = false
}
