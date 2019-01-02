//
//  UIStackView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIStackView {
    func customizeSettings(vertical: Bool = false) {
        self.axis = vertical ? .vertical : .horizontal
        self.spacing = 0
        self.distribution = .fillEqually
        self.alignment = .fill
    }
}
