//
//  AHFUITests.swift
//  AHFUITests
//
//  Created by marcio on 2020-09-06.
//

import XCTest

class AHFUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequest() {
        
        let app = XCUIApplication()
        app.images["house.fill"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element.tap()
        app.navigationBars["REQUEST"].tap()
        
    }
    
    func testDonation() {
        
        let app = XCUIApplication()
        app.images["house.fill"].tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .textView).element.tap()
        element.tap()
        app.tabBars.buttons["DONATION"].tap()
        
        let plusCircleFillButton = app.buttons["plus.circle.fill"]
        plusCircleFillButton.tap()
        plusCircleFillButton.tap()
        
    }
    
    func testDelivery() {
        
        let app = XCUIApplication()
        let houseFillImage = app.images["house.fill"]
        houseFillImage.tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        houseFillImage.tap()
        textView.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["DONATION"].tap()
        
        let plusCircleFillButton = app.buttons["plus.circle.fill"]
        plusCircleFillButton.tap()
        plusCircleFillButton.tap()
        app.navigationBars["AHF.DonationVC"].buttons["DONATE"].tap()
        tabBarsQuery.buttons["DELIVERY"].tap()
        
    }
}
