//
//  AHFTests.swift
//  AHFTests
//
//  Created by marcio on 2020-09-06.
//

import XCTest
@testable import AHF

class AHFTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDoubleExtensions() {
        let double = 1.12345
        XCTAssertEqual(double.dec, Decimal(string: double.description))
        XCTAssertEqual(double.array(precision: 5), [1,12345])
    }
    
    func testIntExtensions() {
        let int = 20200606235900
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        XCTAssertEqual(int.dec, Decimal(int))
        XCTAssertEqual(int.str, String(int))
        XCTAssertEqual(int.date, format.date(from: String(int)))
    }
    
    func testStringExtensions() {
        let string = "10.12345"
        XCTAssertEqual(string.dec, Decimal(string: string))
        XCTAssertEqual("0"*3, "000")
    }
    
    func testDecimalExtensions() {
        let decimal = "10.12345".dec
        XCTAssertEqual(decimal.str, decimal.description)
        XCTAssertEqual(decimal.double, NSDecimalNumber(decimal:decimal).doubleValue)
        XCTAssertEqual(decimal.trunc(at: 1), "10.1".dec)
        XCTAssertEqual(decimal.array(precision: 5), [10,12345])
    }
    
    func testDateExtensions() {
        var components = DateComponents()
        components.year   = 2020
        components.month  = 6
        components.day    = 13
        let calendar = Calendar.current
        let date = calendar.date(from: components)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        XCTAssertEqual(dateFormatter.string(from: date), "2020-06-13 00:00")
        XCTAssertEqual(date.int, 20200613000000)
    }
    
    func testCoord() {
        let strCoord = "10.12345 -20.12345"
        let coord = Coord(str: strCoord)
        
        XCTAssertEqual(Coord.precision, 5)
        XCTAssertEqual(Coord.step,      "0.00001".dec)
        
        XCTAssertEqual(coord.str,     strCoord)
        XCTAssertEqual(coord.strCode, strCoord)
        XCTAssertEqual(coord.array,   [10,12345,-20,-12345])
        XCTAssertEqual(coord.lat,     "10.12345".dec)
        XCTAssertEqual(coord.long,    "-20.12345".dec)
        
        XCTAssertEqual(coord.minMaxNearBy(),
                       [[    10,     10],
                        [ 12335,  12355],
                        [   -20,    -20],
                        [-12355, -12335]] )
    }
}
