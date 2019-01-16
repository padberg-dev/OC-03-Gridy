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
    
    let lineWidth: CGFloat = 4
    let extendSizeBy: CGFloat = 16

    override func draw(_ rect: CGRect) {
        UIColor.black.set()

        let origin = CGPoint(x: negativeX ? bounds.maxX - extendSizeBy : bounds.minX + extendSizeBy,
                             y: negativeY ? bounds.maxY - extendSizeBy : bounds.minY + extendSizeBy)
        let targetPoint = CGPoint(x: negativeX ? bounds.minX + extendSizeBy : bounds.maxX - extendSizeBy,
                                  y: negativeY ? bounds.minY + extendSizeBy : bounds.maxY - extendSizeBy)
        
        let vector = calculateVector(from: origin, to: targetPoint)
        let extendedTargetPoint = CGPoint(x: targetPoint.x * 0.98,
                                     y: targetPoint.y * 0.98)
        drawTriangle(with: vector, from: targetPoint)

        let path = calculateLinePath(from: origin, to: extendedTargetPoint)
        path.stroke()
        
        drawStartCircle(from: origin)
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
    
    func kill() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { [weak self] _ in
            self?.removeFromSuperview()
        }
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
        path.lineWidth = lineWidth
        
        return path
    }
    
    private func initialize() {
        self.contentMode = .redraw
        self.backgroundColor = .clear
    }
    
    private func calculateVector(from startPoint: CGPoint, to secondPoint: CGPoint) -> CGPoint {
        let differenceX = secondPoint.x - startPoint.x
        let differenceY = secondPoint.y - startPoint.y
        
        let cEdge = sqrt(differenceX * differenceX + differenceY * differenceY)
        let scale = cEdge / (3 * lineWidth)
        
        return CGPoint(x: differenceX / scale, y: differenceY / scale)
    }
    
    private func rotateVectorBy90(_ vector: CGPoint, clockwise: Bool) -> CGPoint {
        return CGPoint(x: (clockwise ? -1 : 1) * vector.y,
                       y: (clockwise ? 1 : -1) * vector.x)
    }
    
    // Triangle
    // A: endPoint
    // B: endPoint - vector + vectorClockwise
    // C: endPoint - vector + vectorAntiClockwise
    private func drawTriangle(with vector: CGPoint, from endPoint: CGPoint) {
        let path = UIBezierPath()
        let b = CGPoint(x: endPoint.x - vector.x + rotateVectorBy90(vector, clockwise: true).x,
                        y: endPoint.y - vector.y + rotateVectorBy90(vector, clockwise: true).y)
        let c = CGPoint(x: endPoint.x - vector.x + rotateVectorBy90(vector, clockwise: false).x,
                        y: endPoint.y - vector.y + rotateVectorBy90(vector, clockwise: false).y)
        
        path.move(to: endPoint)
        path.addLine(to: b)
        path.addLine(to: c)
        path.close()
        path.lineWidth = lineWidth
        
        path.stroke()
        path.fill()
    }
    
    private func drawStartCircle(from point: CGPoint) {
        let path = UIBezierPath()
        path.move(to: point)
        path.addArc(withCenter: point, radius: lineWidth * 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        path.lineWidth = lineWidth
        
        UIColor.white.setFill()
        
        path.stroke()
        path.fill()
    }
}
