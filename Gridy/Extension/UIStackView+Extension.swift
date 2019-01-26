//
//  UIStackView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UIStackView {
    // Aplly same setting for many stakViews
    func customizeSettings(vertical: Bool = false) {
        self.axis = vertical ? .vertical : .horizontal
        self.spacing = 0
        self.distribution = .fillEqually
        self.alignment = .fill
    }
    
    // Animates StackView with image tiles to extend its frame to the edges of the screen - 5 points each size
    // At the same time animate spacing between imageTiles so it looks like a full image is sliced into tiles
    func animateSlicing(in view: UIView, to point: CGPoint, extendBy pointsDistance: CGFloat) {
        let numOfStacks = numberOfStackViewsInside
        
        UIView.animate(withDuration: 0.8, animations: {}) { [weak self] _ in
            
            self?.frame.size.width += 2 * pointsDistance
            self?.frame.size.height += 2 * pointsDistance
            
            UIView.animate(withDuration: 0.8, animations: {
                // view.layoutIfNeeded() makes calculation for frame changes and it has to be fired after those changes
                view.layoutIfNeeded()
                
                // Because everything else has no autoLayoutConstraits those animations below are not affected by view.layoutIfNeeded()
                self?.frame.origin.x -= pointsDistance
                self?.frame.origin.y -= pointsDistance
                self?.spacing = (2 * pointsDistance) / CGFloat(numOfStacks - 1)
                self?.subviews.forEach({ (innerStackView) in
                    (innerStackView as! UIStackView).spacing = (2 * pointsDistance) / CGFloat(numOfStacks - 1)
                })
            })
        }
    }
    
    // After slicing animation each of the tiles will be moved to next collectionView but in a randomly generated order so -> this method returns a random UIView from it child stackView
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
