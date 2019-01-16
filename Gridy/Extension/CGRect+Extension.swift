//
//  CGRect+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 13.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension CGRect {
    func scaleDownByHalfPixel() -> CGRect {
        var newRect = CGRect()
        newRect.origin.x = self.origin.x + 0.5
        newRect.origin.y = self.origin.y + 0.5
        newRect.size.width = self.size.width - 1
        newRect.size.height = self.size.height - 1
        return newRect
    }
    
    func extendAllSidesBy(_ points: CGFloat) -> CGRect {
        var newRect = self
        newRect.size.width = self.width + 2 * points
        newRect.size.height = self.height + 2 * points
        newRect.origin.x = self.origin.x - points
        newRect.origin.y = self.origin.y - points
        return newRect
    }
}
