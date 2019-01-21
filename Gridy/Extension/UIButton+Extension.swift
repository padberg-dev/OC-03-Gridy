//
//  UIButton+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIButton {
    func styleSelectButton() {
        self.backgroundColor = StyleGuide.greenMain
        
        self.layer.borderWidth = 2.0
        self.layer.borderColor = StyleGuide.greenDark.cgColor
        
        self.layer.cornerRadius = self.frame.height / 4
        
        self.setTitleColor(StyleGuide.navy, for: .normal)
    }
    
    func makeEnabled(_ enabled: Bool) {
        self.isEnabled = enabled
        self.animateAlpha(to: (enabled ? 1.0 : 0.3))
    }
}
