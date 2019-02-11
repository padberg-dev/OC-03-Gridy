//
//  GameVMTestCase.swift
//  GridyTests
//
//  Created by Rafal Padberg on 11.02.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import XCTest
@testable import Gridy

class GameVMTestCase: XCTestCase {
    
    var game: GameVM?
    let testPhoto = UIImage(named: "AppLaunchScreenLogo")!

    override func setUp() {
        // GIVEN | GameVM at start | Create scoreLabel
        game = GameVM()
        game?.scoreLabel = UILabel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_SlicingTheImage_CheckIfSuccessfull() {
        // GIVEN | setUp()
        
        // WHEN | sliceTheImage of testPhoto into 3-9 tilesPerRow
        let randomNum = Int.random(in: 3 ... 9)
        game?.sliceTheImage(testPhoto, into: randomNum)
        
        // THEN | Check if number of images = tilesPerRow^2
        XCTAssertTrue(game?.getNumberOfTiles() == (randomNum * randomNum))
    }
    
    func test_ConvertingIndexToRowAndColumAndBack_CheckAgainstStaticData() {
        // GIVEN | setUp()
        // WHEN | Image sliced with 7 tilesPerRow
        game?.sliceTheImage(testPhoto, into: 7)
        
        // THEN | Check if indexes convert correctly from and to precalculated values
        let indexTORowAndColumn = [0, 5, 11, 16, 21, 27, 32, 40, 48]
        let rowAndColumn = [[0, 0], [0, 5], [1, 4], [2, 2], [3, 0], [3, 6], [4, 4], [5, 5], [6, 6]]
        
        for i in 0 ..< indexTORowAndColumn.count {
            let convertetInt = game?.convertToIntFrom(row: rowAndColumn[i][0], column: rowAndColumn[i][1])
            XCTAssertTrue(convertetInt == indexTORowAndColumn[i])

            let (conRow, conCol) = game!.getRowAndColumn(from: indexTORowAndColumn[i])
            XCTAssertTrue(conRow == rowAndColumn[i][0] && conCol == rowAndColumn[i][1])
        }
    }
}
