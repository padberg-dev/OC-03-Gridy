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
    
    // To make checks wheter the UIImageView contains an image have less code
    var hasImage: Bool = false
    var index: Int?
}
