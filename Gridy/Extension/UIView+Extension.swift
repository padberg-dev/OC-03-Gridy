//
//  UIView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(by points: CGFloat) {
        self.layer.cornerRadius = points
    }
    
    func animateAlpha(to value: CGFloat = 1, andBackTo backValue: CGFloat? = nil) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = value
        }) { [weak self] _ in
            if let backValue = backValue {
                UIView.animate(withDuration: 0.4) {
                    self?.alpha = backValue
                }
            }
        }
    }
    
    // Creates a smaller frame inside of the view's bounds that is not touching it. Using .evenOdd filling rule, the inside frame will be considered outside of the path and will be masked/not drawn.
    // This is a case in wich paths don't intersect(bounds-path and smaller frame path) and thus every second frame inside will be empty
    func maskView(withHole frame: CGRect) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        
        let path = UIBezierPath(rect: self.bounds)
        path.append(UIBezierPath(rect: frame))
        
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    // Changes each view's alpha to 0 and views that are hidden will be shown(alpha = 1). That only applies to contentView(view containing next VC)
    // Prepares views to be cleaned after animation -> next method -> removeTransparentViews()
    func hideNotNeededUI() {
        UIView.animate(withDuration: 0.6) {
            self.subviews.forEach { (view) in
                view.alpha = view.isHidden ? 1 : 0
            }
        }
        
    }
    
    // Cleans the UI by removing all views, which alpha is 0, from theirs superviews
    func removeTransparentViews() {
        self.subviews.forEach { (view) in
            if view.alpha == 0 {
                view.removeFromSuperview()
            }
        }
    }
    
    // Depending on the orientation the view will be moved up or right out of the screen
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
    
    // Modifies passed variable holding ArrowView by initializing it and adding it to its view.
    func createArrow(view: inout ArrowView?, from startingPoint: CGPoint) {
        view = ArrowView(frame: CGRect(origin: startingPoint, size: .zero))
        self.addSubview(view!)
    }
    
    // This method takes itemIndexes from 2 collectionViews and creates an animation of exchanging Images.
    // After the animation Images will swap places in the collectionViews.
    // Posible to run the animation with only 1 image.
    func moveImages(from startCollectionView: UICollectionView, with startIndex: Int, to endCollectionView: UICollectionView, with endIndex: Int) -> Bool {
        guard let startCell = startCollectionView.cellForItem(at: IndexPath(item: startIndex, section: 0)) as? CustomCollectionViewCell else { fatalError("!!!") }
        guard let endCell = endCollectionView.cellForItem(at: IndexPath(item: endIndex, section: 0)) as? CustomCollectionViewCell else { fatalError("!!!") }
        
        let imageSize = startCell.frame.size
        
        let startHasImage = startCell.hasImage
        let endHasImage = endCell.hasImage
        
        let startPoint = startCollectionView.convert(startCell.frame.origin, to: self)
        let endPoint = endCollectionView.convert(endCell.frame.origin, to: self)
        
        // Force Unwrap will never fail. If there is no image .hasImage-attribute will be false
        let startImage = startHasImage ? UIImageView(image: startCell.imageView.image!) : nil
        let endImage = endHasImage ? UIImageView(image: endCell.imageView.image!) : nil
        
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
        
        UIView.animate(withDuration: 0.4, animations: {
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
        return startHasImage || endHasImage
    }
    
    func createPreview(of image: UIImage, withGridFrame gridFrame: CGRect, isPortraitMode: Bool, above: UIView) {
        let extendBy: CGFloat = 25.0
        
        let previewView = UIView(frame: self.bounds)
        
        let blurView = UIVisualEffectView(frame: self.bounds)
        blurView.effect = UIBlurEffect(style: .dark)
        blurView.alpha = 0
        blurView.animateAlpha(to: 0.9)
        
        previewView.addSubview(blurView)
        
        let imageView = UIImageView(image: image)
        imageView.frame.origin = CGPoint(x: 25, y: 25)
        
        let newView = UIView(frame: gridFrame.extendAllSidesBy(extendBy))
        newView.backgroundColor = StyleGuide.yellowLight
        newView.roundCorners(by: extendBy / 2)
        newView.prepareForSlidingIn(portraitMode: !isPortraitMode, to: self.frame)
        newView.addSubview(imageView)
        
        let progressBar = UIProgressView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: imageView.frame.width, height: 5)))
        progressBar.trackTintColor = .clear
        progressBar.progressViewStyle = .bar
        progressBar.tintColor = StyleGuide.navy
        
        let stack = UIStackView(frame: CGRect(origin: CGPoint(x: 25, y: 13), size: CGSize(width: imageView.frame.width, height: 5)))
        stack.addArrangedSubview(progressBar)
        
        newView.addSubview(stack)
        
        previewView.addSubview(newView)
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            newView.frame.origin.x = gridFrame.origin.x - (isPortraitMode ? extendBy : 0)
            newView.frame.origin.y = gridFrame.origin.y - (isPortraitMode ? 0 : extendBy)
        }, completion: nil)
        
        self.addSubview(previewView)
        
        UIView.animate(withDuration: 2.4) {
            progressBar.setProgress(1, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            previewView.animateAlpha(to: 0)
            previewView.removeFromSuperview()
        }
    }
}
