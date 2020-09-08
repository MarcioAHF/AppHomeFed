//
//  Extensions.swift
//  AHF
//
//  Created by Nano on 20-06-03.
//

import Foundation
import MapKit

//------------------------------------------------------------------------------
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
//------------------------------------------------------------------------------
extension Notification.Name {
    // Notifications
    static let gps = Notification.Name("gps")
    static let dbLocation = Notification.Name("dbLocation")
    static let dbDelivery = Notification.Name("dbDelivery")
}
//------------------------------------------------------------------------------
extension Double {
    public var dec: Decimal { get {
        return Decimal(string: self.description)!
    }}
    public func array(precision:Int) -> [Int] {
        return self.dec.array(precision: precision)
    }
}
//------------------------------------------------------------------------------
extension Int {
    var dec: Decimal {
        return Decimal(self)
    }
    var str: String {
        return String(self)
    }
    var date:Date? {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        return format.date(from: String(self))
    }
}
//------------------------------------------------------------------------------
extension String {
    public var dec: Decimal {
        return Decimal(string: self)! //get{}
    }
    static func * (str: String, repeatTimes: Int) -> String {
        return String(repeating: str, count: repeatTimes)
    }
}
//------------------------------------------------------------------------------
extension Decimal {
    public func array(precision:Int) -> [Int] {
        let zeros = ("0" * precision)
        let minus = self < 0 ? true : false

        var strArray = self.description.components(separatedBy: ".")
        strArray[1] = (minus ? "-" : "") + (strArray[1] + zeros).prefix(precision)

        return [ Int( strArray[0] )!,
                 Int( strArray[1] )! ]
    }
    public func trunc(at:Int) -> Decimal {
        var number = self
        var result = Decimal()
        NSDecimalRound(&result, &number, at, .down)
        return result
    }
    var double:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    public var str: String { get {
        return self.description
    }}
}
//------------------------------------------------------------------------------
extension Date {
    var int:Int? {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        return Int(format.string(from: self))
    }
    func localTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    func timeAgo() -> String {
       let formatter = DateComponentsFormatter()
       formatter.unitsStyle = .full
       formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
       formatter.zeroFormattingBehavior = .dropAll
       formatter.maximumUnitCount = 1
       return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}
//------------------------------------------------------------------------------
