//
//  CustomScrollView.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Delegate-Implementation Variables
    
    weak var rotationDelegate: CustomScrollViewRotationDelegate?
    
    var rotationGestureRecognizer: UIRotationGestureRecognizer?
    var rotationIsCumulative: Bool = false
    var cumulativeRotation: CGFloat = 0
    var tempRotation: CGFloat = 0
    
    var isSnapingEnabled: Bool = false
    var snappingAngle: CGFloat = 0
    
    var isRotationEnabled: Bool {
        set {
            if newValue {
                rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(byReactingTo:)))
                self.addGestureRecognizer(rotationGestureRecognizer!)
            } else {
                self.gestureRecognizers?.removeAll()
            }
        }
        get {
            return (rotationGestureRecognizer != nil) ? true : false
        }
    }
    
    // MARK: - Initializers
    
    func initialize(with image: UIImage) {
        isScrollEnabled = true
        isRotationEnabled = true
        
        maximumZoomScale = 3
        minimumZoomScale = 1
        
        imageView.image = image
        
        imageHeightConstraint.priority = .required
        imageWidthConstraint.priority = .required
    }
    
    // MARK: - Custom Methods
    
    func setContentSize(toFitInGrid size: CGSize? = nil) {
        if let image = imageView.image {
            var newSize = calculateMinSizeToFit(basedOn: (image.size))
            
            imageWidthConstraint.constant = newSize.width
            imageHeightConstraint.constant = newSize.height
            
            if let gridSize = size {
                let scaleX = round(gridSize.width / newSize.width * 10) / 10
                let scaleY = round(gridSize.height / newSize.height * 10) / 10
                minimumZoomScale = max(scaleX, scaleY)
            }
            
            newSize.width *= zoomScale
            newSize.height *= zoomScale
            
            self.contentSize = newSize
        }
    }
    
    func setRotationToZero() {
        UIView.animate(withDuration: 0.6, animations: {
            self.rotationDelegate?.viewForRotation(in: self)?.transform = .identity
        }) { [weak self] (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self?.setZoomScale((self?.zoomScale)!, animated: true)
            })
        }
    }
    
    private func calculateMinSizeToFit(basedOn imageSize: CGSize) -> CGSize {
        let screenSize = UIScreen.main.bounds
        
        let imageRatio = imageSize.width / imageSize.height
        let screenRatio = screenSize.width / screenSize.height
        
        var newSize = CGSize(width: screenSize.width, height: screenSize.height)
        
        if imageRatio > screenRatio {
            // Increase width
            let widthIncrease = ((imageRatio / screenRatio) - 1) * screenSize.width
            newSize.width += widthIncrease
        } else {
            // Increase height
            let heightIncrease = ((screenRatio / imageRatio) - 1) * screenSize.height
            newSize.height += heightIncrease
        }
        return newSize
    }
    
    // MARK: - Delegate-Implementation Methods
    
    @objc private func handleRotation(byReactingTo rotationRecognizer: UIRotationGestureRecognizer) {
        if let rotatingView = rotationDelegate?.viewForRotation(in: self) {
            
            if isZooming { return }
            
            switch rotationRecognizer.state {
            case .began:
                if let angle = rotationDelegate?.scrollView?(self, rotationSnapsToAngle: snappingAngle) {
                    if abs(angle) > 0 {
                        isSnapingEnabled = true
                        self.snappingAngle = angle
                    } else {
                        isSnapingEnabled = false
                    }
                }
                
                if rotationDelegate?.scrollView?(self, cummulativeRotation: (rotationIsCumulative)) != nil, !isSnapingEnabled {
                    rotationRecognizer.rotation = cumulativeRotation
                }
                
                rotationDelegate?.scrollViewDidBeginRotation?(self, with: rotatingView, having: rotationRecognizer.rotation)
            case .changed:
                let fullRotation = rotationRecognizer.rotation
                
                var rotation: CGFloat = 0
                if isSnapingEnabled {
                    rotation = (round(fullRotation / snappingAngle.convertToRadiants()) * snappingAngle.convertToRadiants())
                    rotation += cumulativeRotation
                    tempRotation = rotation
                } else {
                    rotation = fullRotation
                }
                
                rotationDelegate?.scrollViewIsRotating(self, view: rotatingView, by: rotation)
            case .ended:
                if !isSnapingEnabled {
                    cumulativeRotation = reduceRadiants(rotationRecognizer.rotation)
                } else {
                    cumulativeRotation = reduceRadiants(tempRotation)
                }
                rotationDelegate?.scrollViewDidEndRotation?(self, with: rotatingView, rotatedBy: rotationRecognizer.rotation)
            case .cancelled:
                break
            case .failed:
                break
            case .possible:
                break
            }
        }
    }
    
    // MARK: - Custom Helper Methods
    
    private func reduceRadiants(_ radiants: CGFloat) -> CGFloat {
        let twoPi = 2 * CGFloat.pi
        
        if radiants >= twoPi {
            return radiants.truncatingRemainder(dividingBy: twoPi)
        }
        return radiants
    }
}
