//
//  OrderModel.swift
//  MilkShopProject
//
//  Created by CongDev on 12/5/25.
//

struct OrderModel {
    var address: String
    var date: String
    var detail: [DetailOrderModel]
    var idPayment: String
    var idUser: String
    var priceShipping: String
    var statusOrder: String
    var totalPrice: Int
}

struct DetailOrderModel {
    var name: String
    var price: String
    var quantity: Int
    var image: String
}
