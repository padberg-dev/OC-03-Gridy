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

    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()

        let origin = CGPoint(x: negativeX ? bounds.maxX : bounds.minX,
                             y: negativeY ? bounds.maxY : bounds.minY)
        let targetPoint = CGPoint(x: negativeX ? bounds.minX : bounds.maxX,
                                  y: negativeY ? bounds.minY : bounds.maxY)

        let path = calculateLinePath(from: origin, to: targetPoint)
        path.stroke()
    }
    
    // MARK: - Custom Methods
    
    private func calculateLinePath(from origin: CGPoint, to targetPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: targetPoint)
        path.lineWidth = 4
        
        return path
    }
}
