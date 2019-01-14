//
//  ImageEditorVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorVM {
    
    private var fullImage: UIImage?
    private var imageTiles: [GridImage] = []
    private var tilesPerRow: Int = 0
    
    // MARK: - Public Settings
    
    var extendInsetsToGridView: Bool = true
    
    // MARK: - Public API's
    
    func sliceTheImage(_ image: UIImage, into tilesPerRowAndColumn: Int) {
        fullImage = image
        tilesPerRow = tilesPerRowAndColumn
        
        let step = Int(image.size.width) / tilesPerRowAndColumn
        let size = CGSize(width: step, height: step)

        for row in 0 ..< tilesPerRowAndColumn {
            for column in 0 ..< tilesPerRowAndColumn {
                let point = CGPoint(x: column * step, y: row * step)
                let rect = CGRect(origin: point, size: size)
                
                if let newTile = Utilities.cropImage(image, to: rect) {
                    let newGridImage = GridImage(cgImage: newTile.cgImage!)
                    newGridImage.row = row
                    newGridImage.column = column
                    imageTiles.append(newGridImage)
                }
            }
        }
    }
    
    func createImageStackView(ofSize size: CGRect) -> UIStackView {
        let mainStackView = UIStackView(frame: size)
        mainStackView.customizeSettings(vertical: true)
        
        let step = mainStackView.frame.height / CGFloat(tilesPerRow)
        
        for column in 0 ..< tilesPerRow {
            let rowStackView = UIStackView(frame: CGRect(x: 0, y: CGFloat(column) * step, width: size.width, height: step))
            rowStackView.customizeSettings()
            
            for row in 0 ..< tilesPerRow {
                let newImageTile = UIImageView(image: imageTiles[(column * tilesPerRow) + row])
                rowStackView.addArrangedSubview(newImageTile)
            }
            mainStackView.addArrangedSubview(rowStackView)
        }
        return mainStackView
    }
    
    func getRandomPoolOfTilesNumbers() -> [Int] {
        var randomPool = Array(0 ..< getNumberOfTiles())
        randomPool.shuffle()
        return randomPool
    }
    
    func convertIntToRowAndColumn(_ number: Int) -> (Int, Int) {
        let row = Int(number / tilesPerRow)
        let column = number % tilesPerRow
        
        return (row, column)
    }
    
    func convertToIntFrom(row: Int, column: Int) -> Int {
        return tilesPerRow * row + column
    }
    
    func getTileSize() -> CGSize {
        if imageTiles.count > 0 {
            return imageTiles[0].size
        }
        return .zero
    }
    
    func getNumberOfTiles() -> Int {
        return imageTiles.count
    }
    
    func getNumberOfRows() -> Int {
        return tilesPerRow
    }
    
    func checkIfPuzzleSolved(cells array: [CustomCollectionViewCell]) -> Bool {
        var error = false
        for cell in array {
            if let image = cell.imageView.image as? GridImage {
                if cell.index != convertToIntFrom(row: image.row, column: image.column) {
                    error = true
                }
            }
        }
        return !error
    }
    
}
