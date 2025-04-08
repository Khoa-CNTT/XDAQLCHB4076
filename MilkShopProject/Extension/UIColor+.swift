//
//  UIColor+.swift
//  AIPhotoProject

import Foundation
import UIKit

extension UIColor {
    
    public class var eggplant: UIColor { return UIColor(hex: "72449F") }
    public class var lightTeal: UIColor { return UIColor(hex: "92D2CD") }
    public class var lightBrown: UIColor { return UIColor(hex: "CCBC84") }
    public class var robinEgg: UIColor { return UIColor(hex: "74DFF7")}
    public class var lightGrey: UIColor { return UIColor(hex: "D4D3E7")}
    public class var lightAqua: UIColor { return UIColor(hex: "73F7C2")}
    public class var uglyBlue: UIColor { return UIColor(hex: "3B7886")}
    
    public static let hexF36A10 = UIColor(hex: 0xF36A10)
    public static let hex505153 = UIColor(hex: 0x505153)
    public static let hexBBBDBF = UIColor(hex: 0xBBBDBF)
    public static let hex626366 = UIColor(hex: 0x626366)
    public static let hexDE772D = UIColor(hex: 0xDE772D)
    public static let hex73C0E1 = UIColor(hex: 0x73C0E1)
    public static let hexF34336 = UIColor(hex: 0xF34336)
    
    static func random() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        //scanner.sc = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0x00FF00) >> 8
        let b = rgbValue & 0x0000FF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1
        )
    }
    
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1) {
        self.init(red: r.g / 255.0, green: g.g / 255.0, blue: b.g / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = (hex) & 0xFF
        self.init(r: red, g: green, b: blue, alpha: alpha)
    }
    
    func rgb(_ r: Int,_ g: Int,_ b: Int) ->UIColor {
        return rgba(r, g, b, 1)
    }
    
    func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: Int) ->UIColor {
        let red: CGFloat = (r / 255).g
        let green: CGFloat = (g / 255).g
        let blue: CGFloat = (b / 255).g
        let alpha: CGFloat = (a / 255).g
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func rgba(_ r: Int, _ g: Int, _ b: Int, percentAlpha: Int) ->UIColor {
        let red: CGFloat = (r / 255).g
        let green: CGFloat = (g / 255).g
        let blue: CGFloat = (b / 255).g
        let alpha: CGFloat = (percentAlpha / 100).g
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension UIColor {
    var hexString: String {
        cgColor.components![0..<3]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
}
