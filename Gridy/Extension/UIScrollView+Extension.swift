//
//  UIScrollView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 13.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIScrollView {
    // Change edgeInsets by a given point and rescale it by zoomScale
    func changeInsets(with zeroPoint: CGPoint) {
        let scale = zoomScale
        contentInset = UIEdgeInsets(top: -zeroPoint.y, left: -zeroPoint.x, bottom: -zeroPoint.y, right: -zeroPoint.x)
        contentInset.rescaleBy(scale)
    }
    
    // ExtendInset to a gridFrame so the image will be fit not into the screen but into the grid
    // At the end set offsetPoint to an old offsetPoint
    func extendInsets(to frame: CGRect, toOffset point: CGPoint) {
        let leftMargin = frame.minX
        let topMargin = frame.minY
        let rightMargin = self.frame.width - frame.maxX
        let bottomMargin = self.frame.height - frame.maxY
        
        contentInset.left += leftMargin
        contentInset.top += topMargin
        contentInset.right += rightMargin
        contentInset.bottom += bottomMargin
        
        setContentOffset(point, animated: false)
    }
}
