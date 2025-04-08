//
//  Number+Fommatter.swift
//  AIPhotoProject

import Foundation
extension NumberFormatter {

    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()

    static let separatorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        formatter.secondaryGroupingSize = 3
        return formatter
    }()

    static func decimalFormatter(minimumDigits: Int = 3) -> NumberFormatter {
        decimalFormatter.minimumFractionDigits = minimumDigits
        return decimalFormatter
    }

}

extension Numeric {

    func toDecimalString() -> String {
        guard let value = NumberFormatter.decimalFormatter().string(for: self) else {
            return ""
        }
        return value
    }

    func toSeparatorString() -> String {
        guard let value = NumberFormatter.separatorFormatter.string(for: self) else {
            return ""
        }
        return value
    }

}

