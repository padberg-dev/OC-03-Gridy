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
        game = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_SlicingTheImage() {
        // GIVEN | setUp()
        
        // WHEN | slicing image of testPhoto into 3-9 tilesPerRow
        let randomNum = Int.random(in: 3 ... 9)
        game?.sliceTheImage(testPhoto, into: randomNum)
        
        // THEN | Check if number of images = tilesPerRow^2
        XCTAssertTrue(game?.getNumberOfTiles() == (randomNum * randomNum))
        
        // And if tiles are square
        let size = game?.getTileSize()
        XCTAssertTrue(size?.height == size?.width)
    }
    
    func test_ConvertingIndexToRowAndColumAndBack() {
        // GIVEN | setUp()
        
        // WHEN | Image sliced with 7 tilesPerRow
        game?.sliceTheImage(testPhoto, into: 7)
        
        // THEN | Check if indexes convert correctly from and to precalculated values | Only for the case with 7 tilesPerRow
        let indexTORowAndColumn = [0, 5, 11, 16, 21, 27, 32, 40, 48]
        let rowAndColumn = [[0, 0], [0, 5], [1, 4], [2, 2], [3, 0], [3, 6], [4, 4], [5, 5], [6, 6]]
        
        for i in 0 ..< indexTORowAndColumn.count {
            let convertetInt = game?.convertToIntFrom(row: rowAndColumn[i][0], column: rowAndColumn[i][1])
            XCTAssertTrue(convertetInt == indexTORowAndColumn[i])

            let (conRow, conCol) = game!.getRowAndColumn(from: indexTORowAndColumn[i])
            XCTAssertTrue(conRow == rowAndColumn[i][0] && conCol == rowAndColumn[i][1])
        }
    }
    
    func test_PlacingCells() {
        // GIVEN | setUp()
        
        // WHEN | slicing image with 7 tilesPerRow
        game?.sliceTheImage(testPhoto, into: 7)
        
        // THEN 1 | Checking if correctly placed cell returns true
        let testCell = CustomCollectionViewCell(frame: .zero)
        testCell.index = 16
        let image = (game?.imageTiles[0])!
        image.row = 2
        image.column = 2
        // UIImageView -> weak
        testCell.imageView = UIImageView(image: image)
        
        XCTAssertTrue((game?.isCellInCorrectPlace(testCell))!)
        
        // THEN 2 | Checking if not correctly placed cell returns false
        // Makes test's index value not match image row and column values
        testCell.index = 5
        XCTAssertFalse((game?.isCellInCorrectPlace(testCell))!)
    }
    
    func test_solvingPuzzle() {
        // GIVEN | SetUp & image sliced into 25 pieces
        game?.sliceTheImage(testPhoto, into: 5)
        
        // WHEN | Creating array of correctly placed CollectionViewCells
        var cellsArray: [CustomCollectionViewCell] = []
        
        game?.imageTiles.forEach({ (imageTile) in
            let cell = CustomCollectionViewCell(frame: .zero)
            cell.imageView = UIImageView(image: imageTile)
            cell.index = game?.convertToIntFrom(row: imageTile.row, column: imageTile.column)
            cellsArray.append(cell)
        })
        
        // THEN 1 | Number of cells should be 25
        XCTAssertTrue(cellsArray.count == 25)
        
        // THEN 2 | Puzzle should be solved
        let gameSolved = game?.checkIfPuzzleSolved(cells: cellsArray)
        XCTAssertTrue(gameSolved!)
        
        // THEN 3 | Change one cell from the array to be wrongly placed and check again
        cellsArray[0].index = 26
        
        let gameNotSolved = game?.checkIfPuzzleSolved(cells: cellsArray)
        XCTAssertFalse(gameNotSolved!)
    }
}
