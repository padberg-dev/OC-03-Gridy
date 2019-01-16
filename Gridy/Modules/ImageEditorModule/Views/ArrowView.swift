//
//  ArrowView.swift
//  Gridy
//
//  Created by Rafal Padberg on 06.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    
    var negativeX: Bool = false
    var negativeY: Bool = false
    
    let extendSizeBy: CGFloat = 10

    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()

        let origin = CGPoint(x: negativeX ? bounds.maxX - extendSizeBy : bounds.minX + extendSizeBy,
                             y: negativeY ? bounds.maxY - extendSizeBy : bounds.minY + extendSizeBy)
        let targetPoint = CGPoint(x: negativeX ? bounds.minX + extendSizeBy : bounds.maxX - extendSizeBy,
                                  y: negativeY ? bounds.minY + extendSizeBy : bounds.maxY - extendSizeBy)
        
        print(self.frame.origin)
        print(self.bounds.origin)

        let path = calculateLinePath(from: origin, to: targetPoint)
        path.stroke()
    }
    
    // MARK: - Public Methods
    
    func resizeFrameFrom(startPoint: CGPoint, toPoint: CGPoint) {
        let differencePoint = CGPoint(x: toPoint.x - startPoint.x, y: toPoint.y - startPoint.y)
        self.frame.size = CGSize(width: abs(differencePoint.x) + 2 * extendSizeBy,
                                 height: abs(differencePoint.y) + 2 * extendSizeBy)
        negativeX = differencePoint.x < 0
        negativeY = differencePoint.y < 0
        self.frame.origin.x = (negativeX ? toPoint.x : startPoint.x) - extendSizeBy
        self.frame.origin.y = (negativeY ? toPoint.y : startPoint.y) - extendSizeBy
    }
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    // MARK: - Custom Methods
    
    private func calculateLinePath(from origin: CGPoint, to targetPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: targetPoint)
        path.lineWidth = 4
        
        return path
    }
    
    private func initialize() {
        self.contentMode = .redraw
        self.backgroundColor = .clear
    }
}
