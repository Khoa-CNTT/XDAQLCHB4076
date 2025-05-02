//
//  String+.swift
//  AIPhotoProject

import Foundation
import UIKit

extension String {
    var language: String {
        return self.localized()
    }
    
    func image() -> UIImage? {
        let size = CGSize(width: 55, height: 55)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 45)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func toHours() -> String {
        return String(format: "%.2fh", self)
    }
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var uncurrency: String {
        return self.trim()
            .replacingOccurrences(of: "円", with: "")
            .replacingOccurrences(of: ",", with: "")
    }
    var currency: String {
        return (Decimal(string: self.uncurrency)?.formatedPrice) ?? ""
    }
    private var currencyDefault: String {
        return (Decimal(string: self.uncurrency)?.formatedPrice) ?? "0"
    }
    var currencyJapan: String {
        return self.currencyDefault + "円"
    }
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    func toDouble() -> Double {
        return NumberFormatter().number(from: self.uncurrency)?.doubleValue ?? 0
    }
    func isDecimal() -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.locale = Locale.current
        return formatter
            .number(from: self) != nil
    }
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
    func removeSpecialCharsFromString() -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0) }
    }
    
    func convertPriceToInt(_ priceString: String) -> Int? {
        let cleanedPrice = priceString.replacingOccurrences(of: " đ", with: "")
        let cleanedPriceWithoutDot = cleanedPrice.replacingOccurrences(of: ".", with: "")
        
        return Int(cleanedPriceWithoutDot)
    }
}

extension Decimal {
    var formatedPrice: String? {
        Decimal.formatter.string(for: self)
    }
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1000
        return formatter
    }()
}
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

extension RangeReplaceableCollection where Self: StringProtocol {
    mutating func replaceOccurrences<Target: StringProtocol, Replacement: StringProtocol>(of target: Target, with replacement: Replacement, options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) {
        self = .init(replacingOccurrences(of: target, with: replacement, options: options, range: searchRange))
    }
}


extension String {
        public enum DateFormatType {
       
       /// The ISO8601 formatted year "yyyy" i.e. 1997
       case isoYear
       
       /// The ISO8601 formatted year and month "yyyy-MM" i.e. 1997-07
       case isoYearMonth
       
       /// The ISO8601 formatted date "yyyy-MM-dd" i.e. 1997-07-16
       case isoDate
       
       /// The ISO8601 formatted date and time "yyyy-MM-dd'T'HH:mmZ" i.e. 1997-07-16T19:20+01:00
       case isoDateTime
       
       /// The ISO8601 formatted date, time and sec "yyyy-MM-dd'T'HH:mm:ssZ" i.e. 1997-07-16T19:20:30+01:00
       case isoDateTimeSec
       
       /// The ISO8601 formatted date, time and millisec "yyyy-MM-dd'T'HH:mm:ss.SSSZ" i.e. 1997-07-16T19:20:30.45+01:00
       case isoDateTimeMilliSec
       
       /// The dotNet formatted date "/Date(%d%d)/" i.e. "/Date(1268123281843)/"
       case dotNet
       
       /// The RSS formatted date "EEE, d MMM yyyy HH:mm:ss ZZZ" i.e. "Fri, 09 Sep 2011 15:26:08 +0200"
       case rss
       
       /// The Alternative RSS formatted date "d MMM yyyy HH:mm:ss ZZZ" i.e. "09 Sep 2011 15:26:08 +0200"
       case altRSS
       
       /// The http header formatted date "EEE, dd MM yyyy HH:mm:ss ZZZ" i.e. "Tue, 15 Nov 1994 12:45:26 GMT"
       case httpHeader
       
       /// A generic standard format date i.e. "EEE MMM dd HH:mm:ss Z yyyy"
       case standard
       
       /// A custom date format string
       case custom(String)
       
       /// The local formatted date and time "yyyy-MM-dd HH:mm:ss" i.e. 1997-07-16 19:20:00
       case localDateTimeSec
       
       /// The local formatted date  "yyyy-MM-dd" i.e. 1997-07-16
       case localDate
       
       /// The local formatted  time "hh:mm a" i.e. 07:20 am
       case localTimeWithNoon
       
       /// The local formatted date and time "yyyyMMddHHmmss" i.e. 19970716192000
       case localPhotoSave
       
       case birthDateFormatOne
       
       case birthDateFormatTwo
       
       ///
       case messageRTetriveFormat
       
       ///
       case emailTimePreview
       
       var stringFormat:String {
         switch self {
         //handle iso Time
         case .birthDateFormatOne: return "dd/MM/YYYY"
         case .birthDateFormatTwo: return "dd-MM-YYYY"
         case .isoYear: return "yyyy"
         case .isoYearMonth: return "yyyy-MM"
         case .isoDate: return "yyyy-MM-dd"
         case .isoDateTime: return "yyyy-MM-dd'T'HH:mmZ"
         case .isoDateTimeSec: return "yyyy-MM-dd'T'HH:mm:ssZ"
         case .isoDateTimeMilliSec: return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         case .dotNet: return "/Date(%d%f)/"
         case .rss: return "EEE, d MMM yyyy HH:mm:ss ZZZ"
         case .altRSS: return "d MMM yyyy HH:mm:ss ZZZ"
         case .httpHeader: return "EEE, dd MM yyyy HH:mm:ss ZZZ"
         case .standard: return "EEE MMM dd HH:mm:ss Z yyyy"
         case .custom(let customFormat): return customFormat
           
         //handle local Time
         case .localDateTimeSec: return "yyyy-MM-dd HH:mm:ss"
         case .localTimeWithNoon: return "hh:mm a"
         case .localDate: return "yyyy-MM-dd"
         case .localPhotoSave: return "yyyyMMddHHmmss"
         case .messageRTetriveFormat: return "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
         case .emailTimePreview: return "dd MMM yyyy, h:mm a"
         }
       }
        }
    
    func toDate(_ format: DateFormatType = .isoDate) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.stringFormat
        let date = dateFormatter.date(from: self)
        return date
    }
    
    //Substring
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
}

extension String {
    mutating func regReplace(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines])
            let range = NSRange(location: 0, length: self.utf16.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }

    func removeWhitespacesFromString() -> String {

        let filteredChar = self.filter { !$0.isWhitespace }
        return String(filteredChar)
    }
}
