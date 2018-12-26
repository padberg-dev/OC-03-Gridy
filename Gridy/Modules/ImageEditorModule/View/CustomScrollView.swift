//
//  CustomScrollView.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        isScrollEnabled = true
        maximumZoomScale = 3
        minimumZoomScale = 1
    }
    
    func initialize(with photo: UIImage) {
        imageWidthConstraint.isActive = false
        imageHeightConstraint.isActive = false
        
        imageView.frame = CGRect(origin: .zero, size: photo.size)
        imageView.image = photo
        contentSize = photo.size
    }
}
