//
//  UIProgressView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 21.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIProgressView {
    func style() {
        self.progress = 0
        self.alpha = 0
        self.trackTintColor = StyleGuide.greenLight
        self.tintColor = StyleGuide.greenDark
    }
}
