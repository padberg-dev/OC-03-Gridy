//
//  PuzzleGameView.swift
//  Gridy
//
//  Created by Rafal Padberg on 24.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PuzzleGameView: UIView {
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopTOCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeadingTOCollectionView: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playfieldCollectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var playfieldCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var playfieldCollectionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var playfieldCollectionBottomConstraint: NSLayoutConstraint!
    
    func setConstraints(isPortraitMode: Bool) {
        collectionViewWidthConstraint.isActive = !isPortraitMode
        collectionViewHeightConstraint.isActive = isPortraitMode
        collectionViewTrailingConstraint.isActive = isPortraitMode
        collectionViewBottomConstraint.isActive = !isPortraitMode

        containerViewTopConstraint.isActive = !isPortraitMode
        containerViewTopTOCollectionViewConstraint.isActive = isPortraitMode
        containerViewLeadingTOCollectionView.isActive = !isPortraitMode
        containerViewLeadingConstraint.isActive = isPortraitMode

        playfieldCollectionTopConstraint.isActive = !isPortraitMode
        playfieldCollectionLeadingConstraint.isActive = isPortraitMode
        playfieldCollectionTrailingConstraint.isActive = isPortraitMode
        playfieldCollectionBottomConstraint.isActive = !isPortraitMode
        
        self.layoutIfNeeded()
    }
}
