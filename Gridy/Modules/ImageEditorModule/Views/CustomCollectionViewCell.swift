//
//  CustomCollectionViewCell.swift
//  Gridy
//
//  Created by Rafal Padberg on 03.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // To make checks wheter the UIImageView contains an image when swaping cells.
    // Quicker than if let image = ....
    var hasImage: Bool = false
    // PlayfieldCollectionView cells will have their cells assigned index from 0 to numberOfTiles - 1
    // Reason for this is that the collectionViewCell in itself does not contain id/index/item-number. CollectionView's IndexPath has it. 
    // With this index variable, checkIfPuzzleSolved() func will not require whole collectionView to function.
    var index: Int?
}
