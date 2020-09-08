//
//  Coord2D.swift
//  AHF
//
//  Created by Nano on 20-06-11.
//

import Foundation
import MapKit

struct Coord: Hashable, CustomStringConvertible, Encodable, Decodable {
    
    static let precision = 5
    static let step = "0.00001".dec

    var array = [0,0,0,0]
    var lat: Decimal { get {
        let dec = array[1] * (array[0] < 0 ? -1 : 1)
        return Decimal(string: "\(array[0]).\(dec)")!
    }}
    var long: Decimal { get {
        let dec = array[3] * (array[2] < 0 ? -1 : 1)
        return Decimal(string: "\(array[2]).\(dec)")!
    }}
    var strCode: String = ""
    var str: String { get {
        return "\(lat) \(long)"
    }}
    var asCLLocationCoordinate2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D( latitude: lat.double, longitude: long.double )
        }
    }

    // MARK: -
    init( array:[Int] ) {
        self.array = array
        self.strCode = self.str
    }
    init( coord:CLLocationCoordinate2D ) {
        self.array = coordToArray(coord: coord, precision: Coord.precision)
        self.strCode = self.str
    }
    init( str:String ) {
        let arrayStr = str.components( separatedBy: " ")
        let arrayLat = arrayStr[0].dec.array(precision: Coord.self.precision)
        let arrayLong = arrayStr[1].dec.array(precision: Coord.self.precision)
        self.array = [arrayLat[0],arrayLat[1],arrayLong[0],arrayLong[1]]
        self.strCode = self.str
    }
    init( lat:Decimal, long:Decimal ) {
        self.init(coord:CLLocationCoordinate2D( latitude: lat.double, longitude: long.double ))
    }
    init( from decoder: Decoder ) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init( str: try values.decode(String.self, forKey: .strCode) )
    }
    // MARK: -
    func coordToArray(coord:CLLocationCoordinate2D, precision:Int) -> [Int] {
        let arrayLat = coord.latitude.array(precision: precision)
        let arrayLong = coord.longitude.array(precision: precision)
        return [ arrayLat[0], arrayLat[1], arrayLong[0], arrayLong[1] ]
    }
    func minMaxNearBy() -> [[Int]] {
        let shift = Decimal(10 * 2)
        
        let _latMin = lat - Coord.step * shift / 2
        let _latMax = lat + Coord.step * shift / 2
        let _longMin = long - Coord.step * shift / 2
        let _longMax = long + Coord.step * shift / 2

        let latMin = _latMin.array(precision: Coord.precision)
        let latMax = _latMax.array(precision: Coord.precision)
        let longMin = _longMin.array(precision: Coord.precision)
        let longMax = _longMax.array(precision: Coord.precision)
        
        return [ [latMin[0],  latMax[0]],
                 [latMin[1],  latMax[1]],
                 [longMin[0], longMax[0]],
                 [longMin[1], longMax[1]] ]
    }
    // MARK: - Hashable Protocol
    static func == (lhs: Coord, rhs: Coord) -> Bool {
        return lhs.str == rhs.str
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(str)
    }
    // MARK: Protocol Encodable
    enum CodingKeys: String, CodingKey {
        case strCode
    }
    // MARK: Protocol CustomStringConvertible
    var description: String { return str }
}
