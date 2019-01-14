//
//  UIScrollView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 13.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func changeInsets(with zeroPoint: CGPoint) {
        let oldOffset = contentOffset
        let scale = zoomScale
    
        contentInset = UIEdgeInsets(top: -zeroPoint.y, left: -zeroPoint.x, bottom: -zeroPoint.y, right: -zeroPoint.x)
        contentInset.rescaleBy(scale)
    
//        contentOffset = oldOffset
    }
    
    func extendInsets(to frame: CGRect) {
        let leftMargin = frame.minX
        let topMargin = frame.minY
        let rightMargin = self.frame.width - frame.maxX
        let bottomMargin = self.frame.height - frame.maxY
        
        contentInset.left += leftMargin
        contentInset.top += topMargin
        contentInset.right += rightMargin
        contentInset.bottom += bottomMargin
    }
}
