//
//  AdminManagerType.swift
//  MilkShopProject
//
//  Created by CongDev on 11/5/25.
//

import UIKit

enum AdminManagerType: Int,CaseIterable {
    case changeInfo
    case changePassword
    case client
    case invoice
    case product
    case order
    case logout
    
    var iconName: UIImage? {
        switch self {
        case .changeInfo:
            return .icUserAccount
        case .changePassword:
            return .icChangePw
        case .client:
            return .icClient
        case .invoice:
            return .icInvoice
        case .product:
            return .icProduct
        case .order:
            return .icOrder
        case .logout:
            return .icLogout
        }
    }
    
    var name: String {
        switch self {
        case .changeInfo:
            return "Đổi thông tin"
        case .changePassword:
            return "Đổi mật khẩu"
        case .client:
            return "Khách hàng"
        case .invoice:
            return "Hoá đơn"
        case .product:
            return "Sản phẩm"
        case .order:
            return "Đơn hàng"
        case .logout:
            return "Đăng xuất"
        }
    }
}
