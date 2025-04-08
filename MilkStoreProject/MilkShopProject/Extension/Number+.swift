//
//  Number+.swift
//  AIPhotoProject


import Foundation
import UIKit
import GLKit

extension Int {
    var toArray: [Int] {
        var array: [Int] = []
        (0..<self).forEach({ index in
            array.append(index)
        })
        return array
    }
}

//GLboolean, Boolean
extension UInt8 {
  public var boolValue: Bool {
    return self != 0
  }
  
  public init(booleanLiteral value: BooleanLiteralType) {
    self = value ? UInt8(1) : UInt8(0)
  }
}
//GLint
extension Int32 {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = value ? Int32(1) : Int32(0)
  }
}

//long
extension Int {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var b: Int8 {
    return Int8(self)
  }
  
  public var ub: UInt8 {
    return UInt8(self)
  }
  
  public var s: Int16 {
    return Int16(self)
  }
  
  public var us: UInt16 {
    return UInt16(self)
  }
  
  public var i: Int32 {
    return Int32(self)
  }
  
  public var ui: UInt32 {
    return UInt32(self)
  }
  
  public var l: Int {
    return Int(self)
  }
  
  public var ul: UInt {
    return UInt(self)
  }
  
  public var ll: Int64 {
    return Int64(self)
  }
  
  public var ull: UInt64 {
    return UInt64(self)
  }
  func toDuration() -> String {
    let hours = self / 3600
    let minutes = (self % 3600) / 60
    let seconds = (self % 3600) % 60
    return String(format: "%02d:%02d:%02d" , hours, minutes, seconds)
  }
}

//unsigned long, size_t
extension UInt {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var b: Int8 {
    return Int8(self)
  }
  
  public var ub: UInt8 {
    return UInt8(self)
  }
  
  public var s: Int16 {
    return Int16(self)
  }
  
  public var us: UInt16 {
    return UInt16(self)
  }
  
  public var i: Int32 {
    return Int32(self)
  }
  
  public var ui: UInt32 {
    return UInt32(self)
  }
  
  public var l: Int {
    return Int(self)
  }
  
  public var ul: UInt {
    return UInt(self)
  }
  
  public var ll: Int64 {
    return Int64(self)
  }
  
  public var ull: UInt64 {
    return UInt64(self)
  }
}

//GLint, cl_int
extension Int32 {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var b: Int8 {
    return Int8(self)
  }
  
  public var ub: UInt8 {
    return UInt8(self)
  }
  
  public var s: Int16 {
    return Int16(self)
  }
  
  public var us: UInt16 {
    return UInt16(self)
  }
  
  public var i: Int32 {
    return Int32(self)
  }
  
  public var ui: UInt32 {
    return UInt32(self)
  }
  
  public var l: Int {
    return Int(self)
  }
  
  public var ul: UInt {
    return UInt(self)
  }
  
  public var ll: Int64 {
    return Int64(self)
  }
  
  public var ull: UInt64 {
    return UInt64(self)
  }
}

//GLuint, GLenum, GLsizei
extension UInt32 {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var b: Int8 {
    return Int8(self)
  }
  
  public var ub: UInt8 {
    return UInt8(self)
  }
  
  public var s: Int16 {
    return Int16(self)
  }
  
  public var us: UInt16 {
    return UInt16(self)
  }
  
  public var i: Int32 {
    return Int32(self)
  }
  
  public var ui: UInt32 {
    return UInt32(self)
  }
  
  public var l: Int {
    return Int(self)
  }
  
  public var ul: UInt {
    return UInt(self)
  }
  
  public var ll: Int64 {
    return Int64(self)
  }
  
  public var ull: UInt64 {
    return UInt64(self)
  }
}

//Darwin clock_types.h
extension UInt64 {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var b: Int8 {
    return Int8(self)
  }
  
  public var ub: UInt8 {
    return UInt8(self)
  }
  
  public var s: Int16 {
    return Int16(self)
  }
  
  public var us: UInt16 {
    return UInt16(self)
  }
  
  public var i: Int32 {
    return Int32(self)
  }
  
  public var ui: UInt32 {
    return UInt32(self)
  }
  
  public var l: Int {
    return Int(self)
  }
  
  public var ul: UInt {
    return UInt(self)
  }
  
  public var ll: Int64 {
    return Int64(self)
  }
  
  public var ull: UInt64 {
    return UInt64(self)
  }
}

//GLfloat, cl_float
extension Float {
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var d: Double {
    return Double(self)
  }
  
  public var i: Int {
    return Int(self)
  }
  
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
  public var g: CGFloat {
    return CGFloat(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var withDot: String {
    let formater = NumberFormatter()
    formater.locale = Locale(identifier: "en_US")
    formater.groupingSeparator = "."
    formater.numberStyle = .decimal
    let formattedNumber = formater.string(from: NSNumber(floatLiteral: self))
    return formattedNumber ?? "0"
  }
}

extension CGFloat {
  public var d: Double {
    return Double(self)
  }
  
  public var f: Float {
    return Float(self)
  }
  
  public var ci: CInt {
    return CInt(self)
  }
  
  public var i: Int {
    return Int(self)
  }
}

//Int8
extension CChar {
  public init(_ v: UnicodeScalar) {
    self = CChar(v.value)
  }
}

//UInt16
extension unichar {
  public init(_ v: UnicodeScalar) {
    self = unichar(v.value)
  }
}


