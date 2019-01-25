//
//  ImageEditorExtensions.swift
//  Gridy
//
//  Created by Rafal Padberg on 21.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension ImageEditorViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.contentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {        
        resetUI()
        checkIfCanContinue()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            checkIfCanContinue()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkIfCanContinue()
    }
}

extension ImageEditorViewController: CustomScrollViewRotationDelegate {
    
    // MARK: - CustomScrollViewRotationDelegate Methods
    
    func viewForRotation(in scrollView: CustomScrollView) -> UIView? {
        return scrollView.imageView
    }
    
    func scrollViewIsRotating(_ scrollView: CustomScrollView, view: UIView, by radiants: CGFloat) {
        let transform = CGAffineTransform(rotationAngle: radiants)
        view.transform = transform
        angleLabel.text = radiants.convertFromRadiants().getRoundedString()
    }
    
    func scrollViewDidEndRotation(_ scrollView: CustomScrollView, with view: UIView, rotatedBy radiants: CGFloat) {
        print("END ROTATION")
        resetUI()
        checkIfCanContinue()
    }
    
    func scrollView(_ scrollView: CustomScrollView, rotationSnapsToAngle inAngularDegrees: CGFloat) -> CGFloat {
        print("SNAPPING")
        return isSnapingAllowed ? CGFloat(snappingDegree) : 0
    }
    
    func scrollView(_ scrollVIew: CustomScrollView, cummulativeRotation isSet: Bool) -> Bool {
        return true
    }
}
