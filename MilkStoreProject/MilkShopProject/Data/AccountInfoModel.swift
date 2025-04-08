//
//  AccountInfoModel.swift
//  BaloProject
//
//  Created by CongDev on 6/11/24.
//

import Foundation

struct AccountInfoModel: Codable {
    var email: String
    var phone: String
    var username: String
    var role: String
    var address: [String]
    var password: String
    var authcode: String
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "phone": phone,
            "username": username,
            "role": role,
            "address": address,
            "password": password,
            "authcode": authcode
        ]
    }
}

extension AccountInfoModel {
    init?(dictionary: [String: Any]) {
        guard let email = dictionary["email"] as? String,
              let phone = dictionary["phone"] as? String,
              let username = dictionary["username"] as? String,
              let role = dictionary["role"] as? String,
              let address = dictionary["address"] as? [String],
              let password = dictionary["password"] as? String,
              let authcode = dictionary["authcode"] as? String
        else { return nil }
        self.init(email: email, phone: phone, username: username, role: role, address: address, password: password, authcode: authcode)
    }
}
