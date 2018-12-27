//
//  CustomGridView.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomGridView: UIView {
    
    // MARK:- Parameters
    
    private var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    private var color: UIColor = .black { didSet { setNeedsDisplay() } }
    private var gridTilesPerRow: Int = 5 { didSet { setNeedsDisplay() } }
    
    // MARK:- Initializers
    
    override func awakeFromNib() {
        contentMode = .redraw
        layer.borderWidth = 1.0
    }
    
    // MARK:- Public API
    
    func setNumberOf(tiles: Int) {
        gridTilesPerRow = tiles
    }
    
    func getNumberOfTiles() -> Int {
        return gridTilesPerRow
    }
    
    // MARK:- Draw
    
    override func draw(_ rect: CGRect) {
        color.setStroke()
        
        let tileLength = bounds.width / CGFloat(gridTilesPerRow)
        let horizontalLineSize = CGSize(width: bounds.width, height: 0.5)
        
        for i in 1 ..< gridTilesPerRow {
            let origin = CGPoint(x: bounds.origin.x, y: tileLength * CGFloat(i))
            
            var path = calculatePath(from: origin, by: horizontalLineSize)
            path.stroke()
            
            path = calculatePath(from: invert(point: origin), by: invert(size: horizontalLineSize))
            path.stroke()
        }
    }
    
    // MARK:- Custom Methods
    
    private func calculatePath(from origin: CGPoint, by size: CGSize) -> UIBezierPath {
        let path = UIBezierPath(rect: CGRect(origin: origin, size: size))
        path.lineWidth = lineWidth
        
        return path
    }
    
    private func invert(point: CGPoint) -> CGPoint {
        let newPoint = CGPoint(x: point.y, y: point.x)
        return newPoint
    }
    
    private func invert(size: CGSize) -> CGSize {
        let newSize = CGSize(width: size.height, height: size.width)
        return newSize
    }
}
