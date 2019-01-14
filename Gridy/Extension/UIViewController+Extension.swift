//
//  UIViewController+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 13.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIViewController {
    var isPortraitMode: Bool {
        get {
            let bounds = UIScreen.main.bounds
            return bounds.height > bounds.width
        }
    }
}
