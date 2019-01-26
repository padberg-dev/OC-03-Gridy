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
    
    // To not allow to continue while the image is moving disenable selectButton
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        selectButton.makeEnabled(false)
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
        viewModel.playSound(for: .imageMove)
    }
}

extension ImageEditorViewController: CustomScrollViewRotationDelegate {
    
    // MARK: - CustomScrollViewRotationDelegate Methods
    
    func viewForRotation(in scrollView: CustomScrollView) -> UIView? {
        return scrollView.imageView
    }
    
    // Rotate passed view by passed radiants and show in degrees in a label
    func scrollViewIsRotating(_ scrollView: CustomScrollView, view: UIView, by radiants: CGFloat) {
        let transform = CGAffineTransform(rotationAngle: radiants)
        view.transform = transform
        angleLabel.text = radiants.convertFromRadiants().getRoundedString()
    }
    
    func scrollViewDidEndRotation(_ scrollView: CustomScrollView, with view: UIView, rotatedBy radiants: CGFloat) {
        resetUI()
        checkIfCanContinue()
    }
    
    // If snapping is chosen by the user, use snappingDegree as degree otherwise 0
    func scrollView(_ scrollView: CustomScrollView, rotationSnapsToAngle inAngularDegrees: CGFloat) -> CGFloat {
        return isSnapingAllowed ? CGFloat(snappingDegree) : 0
    }
    
    func scrollView(_ scrollVIew: CustomScrollView, cummulativeRotation isSet: Bool) -> Bool {
        return true
    }
}
