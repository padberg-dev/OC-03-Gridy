//
//  CGRect+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 13.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension CGRect {
    // Because minimum zoomScale of the scrollView will be a fractio with x digits after the .
    // There will be some automatic rounding involved and because of that checking if the the grid is inside of the image bounds can be misscalculated approx. by < 0.5 points resulting in showing error when there shouldn't be
    // After scaling down by half point it won't be the case anymore
    // No its possible to have a very thin line of white space being cropped but that's OK because the playfield will have a 1 px border
    func scaleDownByHalfPoint() -> CGRect {
        var newRect = CGRect()
        newRect.origin.x = self.origin.x + 0.5
        newRect.origin.y = self.origin.y + 0.5
        newRect.size.width = self.size.width - 1
        newRect.size.height = self.size.height - 1
        return newRect
    }
    
    // Returns a frame with all sides extended by a given value
    func extendAllSidesBy(_ points: CGFloat) -> CGRect {
        var newRect = self
        newRect.size.width = self.width + 2 * points
        newRect.size.height = self.height + 2 * points
        newRect.origin.x = self.origin.x - points
        newRect.origin.y = self.origin.y - points
        return newRect
    }
}
