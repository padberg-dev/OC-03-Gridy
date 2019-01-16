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
    
    func roundEdges(by points: CGFloat) {
        self.layer.cornerRadius = points
    }
    
    func animateAlpha(toValue: CGFloat = 1) {
        UIView.animate(withDuration: 0.4) {
            self.alpha = toValue
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
    
    func createArrow(view: inout ArrowView?, from startingPoint: CGPoint) {
        view = ArrowView(frame: CGRect(origin: startingPoint, size: .zero))
        self.addSubview(view!)
    }
    
    func moveImages(from startCollectionView: UICollectionView, with startIndex: Int, to endCollectionView: UICollectionView, with endIndex: Int) {
        guard let startCell = startCollectionView.cellFromItem(startIndex) as? CustomCollectionViewCell else { fatalError("!!!") }
        guard let endCell = endCollectionView.cellFromItem(endIndex) as? CustomCollectionViewCell else { fatalError("!!!") }
        
        let imageSize = startCell.frame.size
        
        let startHasImage = startCell.hasImage
        let endHasImage = endCell.hasImage
        
        let startPoint = startCollectionView.convert(startCell.frame.origin, to: self)
        let endPoint = endCollectionView.convert(endCell.frame.origin, to: self)
        
        let startImage = startCell.hasImage ? UIImageView(image: startCell.imageView.image!) : nil
        let endImage = endCell.hasImage ? UIImageView(image: endCell.imageView.image!) : nil
        
        let startImageView = UIView(frame: CGRect(origin: startPoint, size: imageSize))
        let endImageView = UIView(frame: CGRect(origin: endPoint, size: imageSize))
        
        if startHasImage {
            startImageView.addSubview(startImage!)
            addSubview(startImageView)
            startCell.imageView.image = nil
        }
        
        if endHasImage {
            endImageView.addSubview(endImage!)
            addSubview(endImageView)
            endCell.imageView.image = nil
        }
        
        UIView.animate(withDuration: 0.6, animations: {
            if endHasImage {
                endImageView.frame.origin = startPoint
            } else {
                
            }
            if startHasImage {
                startImageView.frame.origin = endPoint
            }
        }) { _ in
            if endHasImage {
                startCell.imageView.image = endImage?.image
                endImageView.removeFromSuperview()
            }
            if startHasImage {
                endCell.imageView.image = startImage?.image
                startImageView.removeFromSuperview()
            }
            startCell.hasImage = endHasImage
            endCell.hasImage = startHasImage
        }
    }
}
