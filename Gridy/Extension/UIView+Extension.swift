//
//  UIView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIView {
    func animateError() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1.0
            }) { [weak self] _ in
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
                    self?.alpha = 0
                }, completion: nil)
            }
        }
    }
}
