//
//  UIView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIView {
    
    func animateError() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, animations: {
                self.alpha = 1.0
            }) { [weak self] _ in
                UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
                    self?.alpha = 0
                }, completion: nil)
            }
        }
    }
    
    func maskView(withHole frame: CGRect) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        
        let path = UIBezierPath(rect: self.bounds)
        path.append(UIBezierPath(rect: frame))
        
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    func hideAllUI() {
        UIView.animate(withDuration: 0.6) {
            self.subviews.forEach { (view) in
                view.alpha = view.isHidden ? 1 : 0
            }
        }
        
    }
    
    func getRidOfHiddenUI() {
        self.subviews.forEach { (view) in
            if view.alpha == 0 {
                view.removeFromSuperview()
            }
        }
    }
    
    func prepareForSlidingIn(portraitMode: Bool, to bounds: CGRect) {
        if portraitMode {
            self.frame.origin.x = 2 * bounds.width
        } else {
            self.frame.origin.y = -2 * bounds.height
        }
        self.isHidden = false
    }
    
    func createNewView(from imageView: UIView) -> UIView {
        let oldFrame = imageView.convert(imageView.bounds, to: self)
        
        imageView.removeFromSuperview()
        imageView.frame.origin = oldFrame.origin
        
        let newView = UIView(frame: oldFrame)
        newView.addSubview(imageView)
        
        return newView
    }
}
