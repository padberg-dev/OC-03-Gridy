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
    
    func animateSlicing(in view: UIView, to point: CGPoint, extendBy pixelsStep: CGFloat) {
        let numOfStacks = numberOfStackViewsInside
        
        UIView.animate(withDuration: 0.8, animations: {}) { _ in
            self.frame.size = CGSize(width: self.frame.width + 2 * pixelsStep, height: self.frame.height + 2 * pixelsStep)
            
            UIView.animate(withDuration: 0.8, animations: {
                view.layoutIfNeeded()
                self.frame.origin.x -= pixelsStep
                self.frame.origin.y -= pixelsStep
                self.spacing = (2 * pixelsStep) / CGFloat(numOfStacks - 1)
                self.subviews.forEach({ (innerStackView) in
                    (innerStackView as! UIStackView).spacing = (2 * pixelsStep) / CGFloat(numOfStacks - 1)
                })
            })
        }
    }
    
    func getRandomImageViewFromInsideStackView(_ number: Int) -> UIView? {
        if let rowStackView = self.subviews[number] as? UIStackView {
            let numberOfSubviews = rowStackView.subviews.count
            let view = rowStackView.subviews[Int.random(in: 0 ..< numberOfSubviews)]
            rowStackView.removeArrangedSubview(view)
            return view
        }
        return nil
    }
    
    var numberOfStackViewsInside: Int {
        return self.subviews.filter({ $0.isKind(of: UIStackView.self) ? true : false }).count
    }
}
