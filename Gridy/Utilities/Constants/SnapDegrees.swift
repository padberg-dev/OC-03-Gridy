//
//  SnapDegrees.swift
//  Gridy
//
//  Created by Rafal Padberg on 30.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import Foundation

struct SnapDegrees {
    var tag = 0
    var degree = 0
    var imageName = ""
    
    init(buttonTag: Int) {
        self.tag = buttonTag + 1
        
        switch self.tag {
        case 1:
            degree = 30
        case 2:
            degree = 45
        case 3:
            degree = 90
        default:
            self.tag = 0
            degree = 15
        }
        self.imageName = String(degree)
    }
}
