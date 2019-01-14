//
//  UINavigationController+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 03.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
}
