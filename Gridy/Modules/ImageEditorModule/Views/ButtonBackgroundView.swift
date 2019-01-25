//
//  ButtonBackgroundView.swift
//  Gridy
//
//  Created by Rafal Padberg on 24.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class ButtonBackgroundView: UIView {

    override func awakeFromNib() {
        self.backgroundColor = StyleGuide.yellowLight.withAlphaComponent(0.05)
        self.layer.cornerRadius = self.bounds.width / 4
    }
}
