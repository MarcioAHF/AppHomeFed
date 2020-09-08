//
//  Global.swift
//  AHF
//
//  Created by Nano on 20-06-01.
//

import Foundation
import MapKit

let dbQueue = DispatchQueue(label: "Database Queue")
let dbSemaphore = DispatchSemaphore(value: 1)

let storageQueue = DispatchQueue(label: "Storage Queue")
let storageSemaphore = DispatchSemaphore(value: 1)

struct Next {
    var seq = [0,0,0]
    static var s = Next()
    static var user:     String { Next.s.seq[0] += 1; return String(Next.s.seq[0]) }
    static var event:    String { Next.s.seq[1] += 1; return String(Next.s.seq[1]) }
    static var delivery: String { Next.s.seq[2] += 1; return String(Next.s.seq[2]) }
}
//------------------------------------------------------------------------------
struct k {
    static let null = "nil"
    static let icon = ["home","food"]
    static let typeDesc = [EventType.request:"Request",
                           EventType.donation:"Donation"]

    // Firestore Collections
    static let deliveries = "deliveries"
    static let events = "events"
    static let locations = "locations"
    static let users = "users"

    // Firestore Fields
    static let id = "id"
    static let coordField = ["latInt","latDec","longInt","longDec"]
    static let coord = "coord"
    static let datetime = "datetime"
    static let exists = "exists"
    static let idEvent = "idEvent"
    static let idUser = "idUser"
    static let loc = "loc"
    static let name = "name"
    static let photo = "photo"
    static let qty = "qty"
    static let status = "status"
    static let text = "text"
    static let type = "type"

    // UserDefaults
    static let lastPhotoDonation = "lastPhotoDonation"
    static let lastTextDonation = "lastTextDonation"
    static let lastTextRequest = "lastTextRequest"
    
}
//------------------------------------------------------------------------------
enum EventType: Int, Encodable, Decodable {
    case request = 0
    case donation = 1
}
//------------------------------------------------------------------------------
enum Status: String, Codable {
    case inactive = "I"
    case active   = "A"
}
//------------------------------------------------------------------------------
func coord( lat:Double, long:Double ) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D( latitude: lat, longitude: long )
}
//------------------------------------------------------------------------------
func randomColor() -> UIColor{
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}
//------------------------------------------------------------------------------
