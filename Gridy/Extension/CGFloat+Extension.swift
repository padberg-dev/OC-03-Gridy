//
//  CGFloat+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension CGFloat {
    // Degree to radiants
    func convertToRadiants() -> CGFloat {
        return self / 180 * CGFloat.pi
    }
    
    // Radiants to degree
    func convertFromRadiants() -> CGFloat {
        return self * 180 / CGFloat.pi
    }
    
    // Returns a string of itself rounded to 2 digits accuracy with degree-sign
    func getRoundedString() -> String {
        let num = (self * 100).rounded() / 100
        return "\(num)°"
    }
}
