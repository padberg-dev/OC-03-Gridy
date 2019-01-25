//
//  CGFloat+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension CGFloat {
    func convertToRadiants() -> CGFloat {
        return self / 180 * CGFloat.pi
    }
    
    func convertFromRadiants() -> CGFloat {
        return self * 180 / CGFloat.pi
    }
    
    func getRoundedString() -> String {
        let num = (self * 100).rounded() / 100
        return "\(num)°"
    }
}
