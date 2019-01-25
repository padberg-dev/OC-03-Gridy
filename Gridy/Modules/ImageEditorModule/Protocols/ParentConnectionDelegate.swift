//
//  ParentConnectionDelegate.swift
//  Gridy
//
//  Created by Rafal Padberg on 21.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

protocol ParentConnectionDelegate: class {
    func didMoveAnImageOnTheGrid(withImage: Bool)
    func didStartArrowAnimation(with index: Int)
    func shouldResizeArrowFrame(to point: CGPoint)
    func didEndArrowAnimation(extended: Bool)
}
