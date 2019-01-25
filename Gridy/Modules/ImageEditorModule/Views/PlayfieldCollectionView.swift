//
//  PlayfieldCollectionView.swift
//  Gridy
//
//  Created by Rafal Padberg on 06.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PlayfieldCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var parentConnectionDelegate: ParentConnectionDelegate?
    
    var layout: UICollectionViewFlowLayout!
    var numberOfTiles: Int = 0
    var panGesture: UIPanGestureRecognizer! {
        didSet {
            self.addGestureRecognizer(panGesture)
        }
    }
    var startingGridIndex: Int!
    var gridIndexOld: Int?
    var gameViewModel: GameVM!
    
    // MARK: - Gesture Recognizer Methods
    
    @objc private func handlePan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            break
        case .cancelled:
            break
        case .changed:
            let movePoint = panRecognizer.location(in: self)
            parentConnectionDelegate?.shouldResizeArrowFrame(to: movePoint)
            
            if gridIndexOld != nil {
                cellForItem(at: IndexPath(item: gridIndexOld!, section: 0))?.clearHighlight()
            }
            if let index = self.getGridItem(of: movePoint) {
                cellForItem(at: IndexPath(item: index, section: 0))?.highlight()
                gridIndexOld = index
            } else {
                if gridIndexOld != nil {
                    parentConnectionDelegate?.didEndArrowAnimation(extended: true)
                }
                gridIndexOld = nil
            }
        case .ended:
            parentConnectionDelegate?.didEndArrowAnimation(extended: false)
            
            if gridIndexOld != nil {
                cellForItem(at: IndexPath(item: gridIndexOld!, section: 0))?.clearHighlight()
                let wasImageMoved = moveImages(from: self, with: startingGridIndex, to: self, with: gridIndexOld!)
                gameViewModel.moveMade(wasImageMoved)
                parentConnectionDelegate?.didMoveAnImageOnTheGrid(withImage: wasImageMoved)
            }
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.highlight()
        
        startingGridIndex = indexPath.item
        parentConnectionDelegate?.didStartArrowAnimation(with: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.clearHighlight()
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTiles
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playfieldCell", for: indexPath) as? CustomCollectionViewCell else {
            fatalError("NO playfieldCell??")
        }
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        cell.index = indexPath.item
        return cell
    }
    
    // MARK: - Custom Public Mehtods
    
    func prepareGridFor(tilesPerRow: CGFloat) {
        let height = self.frame.height
        let cellHeight: CGFloat = CGFloat(Int(height / tilesPerRow))
        let differenceOfPixels = height - tilesPerRow * cellHeight
        
        let topInset: CGFloat = differenceOfPixels > 0 ? 1 : 0
        let lineSpacing = differenceOfPixels > 3 ? (differenceOfPixels - topInset) / tilesPerRow : 0
        
        layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = 0
            
        numberOfTiles = Int(tilesPerRow * tilesPerRow)
        
        self.allowsSelection = true
        self.isScrollEnabled = false
        self.reloadData()
        self.animateAlpha()
    }
}
