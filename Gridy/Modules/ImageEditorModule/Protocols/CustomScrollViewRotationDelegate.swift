//
//  CustomScrollViewRotationDelegate.swift
//  Gridy
//
//  Created by Rafal Padberg on 26.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

// Custom protocol for scrollViews rotation functionalities
@objc protocol CustomScrollViewRotationDelegate: class {
    
    func viewForRotation(in scrollView: CustomScrollView) -> UIView?
    func scrollViewIsRotating(_ scrollView: CustomScrollView, view: UIView, by radiants: CGFloat)
    
    @objc optional func scrollView(_ scrollVIew: CustomScrollView, cummulativeRotation isSet: Bool) -> Bool
    @objc optional func scrollView(_ scrollView: CustomScrollView, rotationSnapsToAngle inAngularDegrees: CGFloat) -> CGFloat
    @objc optional func scrollViewDidBeginRotation(_ scrollView: CustomScrollView, with view: UIView, having radiants: CGFloat)
    @objc optional func scrollViewDidEndRotation(_ scrollView: CustomScrollView, with view: UIView, rotatedBy radiants: CGFloat)
}
