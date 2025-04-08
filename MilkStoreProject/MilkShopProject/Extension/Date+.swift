//
//  Date+.swift
//  AIPhotoProject

import Foundation
extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    func toDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toDate1() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
    }
//    func startOfMonth() -> Date {
//           return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
//       }
//
//       func endOfMonth() -> Date {
//           return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
//       }
    
    func startofcurrentyear () -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return  calendar.date(from: components)!
    }
    
    //MARK: - MONTH -
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    
    func toAgoDisplayShort() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        if secondsAgo < minute {
            return "\(secondsAgo) s"
        }
        
        else if secondsAgo < hour {
            return "\(secondsAgo / minute) m"
        }
        else if secondsAgo < day {
            return "\(secondsAgo / hour) h"
        }
        else if secondsAgo < week {
            return "\(secondsAgo / day) days"
        }
        return "\(secondsAgo / week) weeks"
    }
}
import Foundation

open class MessageKitDateFormatter {

    // MARK: - Properties

    public static let shared = MessageKitDateFormatter()

    private let formatter = DateFormatter()

    // MARK: - Initializer

    private init() {}

    // MARK: - Methods

    public func string(from date: Date) -> String {
        configureDateFormatter(for: date)
        return formatter.string(from: date)
    }

    public func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let dateString = string(from: date)
        return NSAttributedString(string: dateString, attributes: attributes)
    }

    open func configureDateFormatter(for date: Date) {
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
            formatter.dateFormat = "EEEE h:mm a"
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
            formatter.dateFormat = "E, d MMM, h:mm a"
        default:
            formatter.dateFormat = "MMM d, yyyy, h:mm a"
        }
    }
    
}

extension Date {
    
    public enum DateFormat: String {
        case ddMMyyyy = "dd/MM/yyyy"
        case yyyyMMdd = "yyyy-MM-dd"
        case ddMMyy = "dd/MM/yy"
        case MMyy = "MM/yy"
        case MMyyyy = "MM/yyyy"
        case yyyy = "yyyy"
        case yyyyMMdd_hhmmss = "yyyy-MM-dd hh:mm:ss"
        case yyyyMMdd_HHmmss = "yyyy-MM-dd HH:mm:ss"
        case ddMMyyyy_hhMMa = "dd MMM yyyy hh:mma"
        case ddMMMyyyy = "dd MMM yyyy"
        case MMMddyyyy = "MMM dd, yyyy"
        case MMMyyyy = "MMM yyyy"
        case MMMM = "MMMM"
    }
    
    public init(_ dateString: String, format: DateFormat, localized: Bool = true) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = localized ? TimeZone.current : TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        
        if let date = dateFormatter.date(from: dateString) {
            self.init(timeInterval: 0, since: date)
        } else {
            self.init(timeInterval: 0, since: Date())
        }
    }
    
    public func toString(format: String, localized: Bool = true) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.timeZone = localized ? TimeZone.current : TimeZone(abbreviation: "UTC")
        return fmt.string(from: self)
    }
    
    public func days(to dateB: Date) -> Int? {
        let diffInDays = Calendar.current.dateComponents([.day], from: self, to: dateB).day
        return diffInDays
    }
    
    func format(to format: DateFormat, localized: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = localized ? TimeZone.current : TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
    
    static func format(from format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.yyyyMMdd_HHmmss.rawValue
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: format)
        return date
    }
    
    static func formatToLetters(from dateString: String) -> String {
        let date = Date(dateString, format: DateFormat.yyyyMMdd_HHmmss)
        let month = Calendar.current.dateComponents([.month], from: date).month!
        let day = Calendar.current.dateComponents([.day], from: date).day!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        let year = Calendar.current.component(.year, from: date)
        
        return "\(monthName) \(day), \(year)"
    }
    
    func contains(_ date: Date) -> Bool {
        return self.years(from: date) == 0
    }
    
    public var isToDay: Bool {
        return self.format(to: .ddMMMyyyy) == Date().format(to: .ddMMMyyyy)
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

extension Date {
    
    func getDaysInMonth() -> Int{
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
}

extension Date {
    
    var year: Int {
        return Calendar.current.dateComponents([.year], from: self).year ?? 0
    }
    
    var month: Int {
        return Calendar.current.dateComponents([.month], from: self).month ?? 0
    }
    
    var day: Int {
        return Calendar.current.dateComponents([.day], from: self).day ?? 0
    }
    
    var hour: Int {
        return Calendar.current.dateComponents([.hour], from: self).hour ?? 0
    }
    
    var minute: Int {
        return Calendar.current.dateComponents([.minute], from: self).minute ?? 0
    }
    
    var second: Int {
        return Calendar.current.dateComponents([.second], from: self).second ?? 0
    }
    
    func year(_ fotmat: String = "yyyy") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
    
    func month(_ fotmat: String = "MM") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
    
    func day(_ fotmat: String = "dd") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
    
    func hour(_ fotmat: String = "HH") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
    
    func minute(_ fotmat: String = "mm") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
    
    func second(_ fotmat: String = "ss") -> Int {
        return Int(self.toString(format: fotmat)) ?? 0
    }
}
