//
//  GridyUITests.swift
//  GridyUITests
//
//  Created by Rafal Padberg on 11.02.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import XCTest
@testable import Gridy

class GridyUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Move the image to the left, right and bottom Edge and check each time if selectButton is enabled (it should be enabled in all cases)
    func testMovingScrollViewToTheEdges() {
        let app = XCUIApplication()
        app.buttons["Gridy Button"].tap()
        
        let selectButton = app.buttons["SELECT"]
        let scrollView = app.scrollViews.element
        
        scrollView.swipeRight()
        XCTAssertTrue(selectButton.isEnabled)
        
        scrollView.swipeLeft()
        XCTAssertTrue(selectButton.isEnabled)
        
        scrollView.swipeUp()
        XCTAssertTrue(selectButton.isEnabled)
    }
    
    // Rotate Image to the point where it will be out of the Grid | Check that the selectButton is not enabled
    // Tap reset Rotation button, it should make selectButton enabled again
    // Change orientation to landscape and back and make sure selectButton stays enabled
    func testRotatingScrollViewOutsideGridAndAutoResetRotationBack() {
        let app = XCUIApplication()
        app.buttons["Gridy Button"].tap()
        
        let selectButton = app.buttons["SELECT"]
        let scrollView = app.scrollViews.element
        
        scrollView.rotate(0.8, withVelocity: 1)
        scrollView.swipeRight()
        scrollView.swipeDown()
        
        XCTAssertFalse(selectButton.isEnabled)
        
        app.buttons["reset"].tap()
        
        let expectation = XCTestExpectation(description: "waitForASec")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(selectButton.isEnabled)
        
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(selectButton.isEnabled)
        
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(selectButton.isEnabled)
    }
}
