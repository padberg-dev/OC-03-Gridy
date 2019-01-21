//
//  UICollectionView+Extension.swift
//  Gridy
//
//  Created by Rafal Padberg on 14.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func getGridItem(of point: CGPoint) -> Int? {
        let index = self.indexPathForItem(at: point)
        if let id = index?.item {
            return id
        }
        return nil
    }
    
    func getCenterPointOf(cell index: Int) -> CGPoint? {
        if let cell = cellForItem(at: IndexPath(item: index, section: 0)) {
            let point = CGPoint(x: cell.frame.origin.x + cell.bounds.midX, y: cell.frame.origin.y + cell.bounds.midY)
            return point
        }
        return nil
    }
}
