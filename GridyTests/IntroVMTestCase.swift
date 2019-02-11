//
//  IntroVMTestCase.swift
//  GridyTests
//
//  Created by Rafal Padberg on 11.02.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import XCTest
@testable import Gridy

class IntroVMTestCase: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_ChosingRandomPhoto_ShouldReceiveStringOfAnImageAsset() {
        // GIVEN | IntroViewModel is at start
        let introVM = IntroViewModel()
        
        // WHEN | chooseRandomPhoto() fired
        let imageString = introVM.chooseRandomPhoto()
        
        // THEN | Return not empty string that can create UIImage
        XCTAssertTrue(imageString != "")
        if UIImage(named: imageString) != nil {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
}
