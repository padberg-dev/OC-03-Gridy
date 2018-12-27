//
//  CustomScrollView.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    // MARK:- Outlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    
    // MARK:- Initializers
    
    func initialize(with image: UIImage) {
        isScrollEnabled = true
        isRotationEnabled = true
        
        maximumZoomScale = 3
        minimumZoomScale = 1
        
        imageView.image = image
        
        imageHeightConstraint.priority = .required
        imageWidthConstraint.priority = .required
    }
    
    // MARK:- Custom Methods
    
    func setContentSize() {
        if let image = imageView.image {
            let newSize = calculateMinSizeToFit(basedOn: (image.size))
            
            imageWidthConstraint.constant = newSize.width
            imageHeightConstraint.constant = newSize.height
            
            self.contentSize = newSize
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
    
    // MARK: - CustomScrollViewRotationDelegate Implementations
    // MARK: - Implementation Variables
    
    weak var rotationDelegate: CustomScrollViewRotationDelegate?
    
    var rotationGestureRecognizer: UIRotationGestureRecognizer?
    var rotationIsCumulative: Bool = false
    var isSnapingEnabled: Bool = false
    var snappingAngle: CGFloat = 0
    var isRotationEnabled: Bool {
        set {
            if newValue {
                rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(rotationRecognizer:)))
                self.addGestureRecognizer(rotationGestureRecognizer!)
            } else {
                self.gestureRecognizers?.removeAll()
            }
        }
        get {
            return (rotationGestureRecognizer != nil) ? true : false
        }
    }
    
    var cumulativeRotation: CGFloat = 0
    
    // MARK:- Implementation Methods
    
    @objc private func handleRotation(rotationRecognizer: UIRotationGestureRecognizer) {
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
                
                if rotationDelegate?.scrollView?(self, cummulativeRotation: (rotationIsCumulative)) != nil {
                    rotationRecognizer.rotation = cumulativeRotation
                }
                
                rotationDelegate?.scrollViewDidBeginRotation?(self, with: rotatingView, having: rotationRecognizer.rotation)
            case .changed:
                let fullRotation = rotationRecognizer.rotation
                let rotation = isSnapingEnabled ? round(fullRotation / snappingAngle.convertToRadiants()) : fullRotation
                
                rotationDelegate?.scrollViewIsRotating(self, view: rotatingView, by: rotation)
            case .ended:
                cumulativeRotation = reduceRadiants(rotationRecognizer.rotation)
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
    
    // MARK:- Custom Helper Methods
    
    private func reduceRadiants(_ radiants: CGFloat) -> CGFloat {
        let twoPi = 2 * CGFloat.pi
        
        if radiants >= twoPi {
            return radiants.truncatingRemainder(dividingBy: twoPi)
        }
        return radiants
    }
}
