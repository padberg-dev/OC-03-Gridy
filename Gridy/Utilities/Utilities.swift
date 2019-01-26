//
//  Utilities.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class Utilities {
    static func cropImage(_ image: UIImage, to newFrame: CGRect) -> UIImage? {
        if let croppedImage = image.cgImage?.cropping(to: newFrame) {
            return UIImage(cgImage: croppedImage)
        }
        return nil
    }
    
    static func takeSnapshot(from contextView: UIView) -> UIImage? {
        var newImage: UIImage?
        
        UIGraphicsBeginImageContext(contextView.frame.size)
        contextView.drawHierarchy(in: contextView.frame, afterScreenUpdates: true)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            newImage = image
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
