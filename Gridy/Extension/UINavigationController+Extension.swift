//
//  UINavigationController+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 03.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UINavigationController {
    // For autorotate blocking
    // In a navigationController shouldAutorotate-attribute of each ViewController will be overrided by navigationontroller's shouldAutorotate
    // Change it so that navigationController will always ask it vissibleController for shouldAutorotate-attribute
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
}
