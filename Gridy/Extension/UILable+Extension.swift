//
//  UILable+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 23.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UILabel {
    // Creates an animation for changing a text
    // It makes it bigger when increasing alpha and then smaller again with decreasing alpha
    func animateSubtraction(with number: Int) {
        self.text = String(number)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { (_) in
            UIView.animate(withDuration: 1.6, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            })
        }
        
    }
}
