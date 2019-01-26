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
    // The frame of  will be extended to all sides by this ammount
    let extendSizeBy: CGFloat = 16
    
    var isAnimatingRemoval: Bool = false
    
    // Draw calculation takes into account that the frame will be extended
    // It draws a line, a triangle that is allways of same size and positioned 90 degree to the direction of the line
    // It draws also a filled circle at the starting point
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        
        let origin = CGPoint(x: negativeX ? bounds.maxX - extendSizeBy : bounds.minX + extendSizeBy,
                             y: negativeY ? bounds.maxY - extendSizeBy : bounds.minY + extendSizeBy)
        let targetPoint = CGPoint(x: negativeX ? bounds.minX + extendSizeBy : bounds.maxX - extendSizeBy,
                                  y: negativeY ? bounds.minY + extendSizeBy : bounds.maxY - extendSizeBy)
        
        let vectorPoint = calculateVPoint(from: origin, to: targetPoint)
        let extendedTargetPoint = CGPoint(x: targetPoint.x * 0.98,
                                          y: targetPoint.y * 0.98)
        drawTriangle(with: vectorPoint, from: targetPoint)
        
        let path = getLinePath(from: origin, to: extendedTargetPoint)
        path.stroke()
        
        drawStartCircle(from: origin)
    }
    
    // MARK: - Public Methods
    
    // Resizes frame and origin of the ArrowView from startPoit to endPoint
    // In addition to that it also extends all sides by extendSizeBy-ammount
    // But if arrowView is being removed don't resize anything
    func resizeFrameFrom(startPoint: CGPoint, toPoint: CGPoint) {
        if !isAnimatingRemoval {
            let differencePoint = CGPoint(x: toPoint.x - startPoint.x, y: toPoint.y - startPoint.y)
            self.frame.size = CGSize(width: abs(differencePoint.x) + 2 * extendSizeBy,
                                     height: abs(differencePoint.y) + 2 * extendSizeBy)
            negativeX = differencePoint.x < 0
            negativeY = differencePoint.y < 0
            self.frame.origin.x = (negativeX ? toPoint.x : startPoint.x) - extendSizeBy
            self.frame.origin.y = (negativeY ? toPoint.y : startPoint.y) - extendSizeBy
        }
    }
    
    // Animates removal of the arrowView
    // sets isAnimating to true so that it won't be resized anymore
    func animatedRemoval(extendedDuration: Bool = false) {
        isAnimatingRemoval = true
        let duration = extendedDuration ? 0.7 : 0.3
        
        UIView.animate(withDuration: duration, animations: {
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
    
    // A line path from point A to B
    private func getLinePath(from origin: CGPoint, to targetPoint: CGPoint) -> UIBezierPath {
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
    
    // Calculates length of line from point A to B -> cEdge
    // This lenght will be scaled to be of certain length (3 * linewidth)
    // Returned point will have the same direction as cEdge but it will have fixed length
    private func calculateVPoint(from startPoint: CGPoint, to secondPoint: CGPoint) -> CGPoint {
        let differenceX = secondPoint.x - startPoint.x
        let differenceY = secondPoint.y - startPoint.y
        
        let cEdge = sqrt(differenceX * differenceX + differenceY * differenceY)
        let scale = cEdge / (3 * lineWidth)
        
        return CGPoint(x: differenceX / scale, y: differenceY / scale)
    }
    
    // Rotates given point by 90 degree
    private func rotatePointBy90(_ point: CGPoint, clockwise: Bool) -> CGPoint {
        return CGPoint(x: (clockwise ? -1 : 1) * point.y,
                       y: (clockwise ? 1 : -1) * point.x)
    }
    
    // Triangle
    // A: endPoint
    // B: endPoint - vectorPoint + vectorPointClockwise
    // C: endPoint - vectorPoint + vectorPointAntiClockwise
    private func drawTriangle(with vectorPoint: CGPoint, from endPoint: CGPoint) {
        let path = UIBezierPath()
        let b = CGPoint(x: endPoint.x - vectorPoint.x + rotatePointBy90(vectorPoint, clockwise: true).x,
                        y: endPoint.y - vectorPoint.y + rotatePointBy90(vectorPoint, clockwise: true).y)
        let c = CGPoint(x: endPoint.x - vectorPoint.x + rotatePointBy90(vectorPoint, clockwise: false).x,
                        y: endPoint.y - vectorPoint.y + rotatePointBy90(vectorPoint, clockwise: false).y)
        
        path.move(to: endPoint)
        path.addLine(to: b)
        path.addLine(to: c)
        path.close()
        path.lineWidth = lineWidth
        
        path.stroke()
        path.fill()
    }
    
    // Draws a circle with its center in point
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
