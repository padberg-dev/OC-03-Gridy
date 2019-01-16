//
//  UICollectionViewCell.swift
//  Gridy
//
//  Created by Rafal Padberg on 14.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    func highlight() {
        self.layer.borderWidth = self.frame.size.width / 2
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
    
    func clearHighlight() {
        self.layer.borderWidth = 0
    }
}
