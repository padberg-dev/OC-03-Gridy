//
//  ImageEditorVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

struct ImageTile: Equatable {
    let image: UIImage
    
    let row: Int
    let column: Int
    
    static func == (lhs: ImageTile, rhs: ImageTile) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}

class ImageEditorVM {
    
    private var fullImage: UIImage?
    private var imageTiles: [ImageTile] = []
    
    // MARK:- Public API's
    
    func sliceTheImage(_ image: UIImage, into tilesPerRowAndColumn: Int) {
        fullImage = image
        
        let step = Int(image.size.width) / tilesPerRowAndColumn
        let size = CGSize(width: step, height: step)

        for column in 0 ..< tilesPerRowAndColumn {
            for row in 0 ..< tilesPerRowAndColumn {
                let point = CGPoint(x: row * step, y: column * step)
                let rect = CGRect(origin: point, size: size)
                
                if let newTile = Utilities.cropImage(image, to: rect) {
                    imageTiles.append(ImageTile(image: newTile, row: row, column: column))
                }
            }
        }
    }
    
    func getImageArray() -> [UIImage] {
        var imageArray: [UIImage] = []
        
        imageTiles.forEach { imageArray.append($0.image) }
        
        return imageArray
    }
}
