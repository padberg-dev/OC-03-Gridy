//
//  UIEdgeInset+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    // Rescales itself by a given scale
    mutating func rescaleBy(_ scale: CGFloat) {
        self.top *= scale
        self.right *= scale
        self.bottom *= scale
        self.left *= scale
    }
}
