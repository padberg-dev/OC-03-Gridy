//
//  PlayfieldCollectionView.swift
//  Gridy
//
//  Created by Rafal Padberg on 06.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PlayfieldCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Attributes
    
    // Delegate for parent child connection
    weak var parentConnectionDelegate: ParentConnectionDelegate?
    
    var gameViewModel: GameVM!
    var layout: UICollectionViewFlowLayout!
    
    // Whole gestureRecognizer logic same as in in PuzzleGameViewController
    var startingGridIndex: Int!
    var gridIndexOld: Int?
    var panGesture: UIPanGestureRecognizer! {
        didSet {
            self.addGestureRecognizer(panGesture)
        }
    }
    
    // MARK: - Gesture Recognizer Methods
    
    // Very similar to handlePan(:) in PuzzleGameViewController
    // Difference is that is uses delegate for some of the actions
    @objc private func handlePan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
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
            cellForItem(at: IndexPath(item: startingGridIndex, section: 0))?.clearHighlight()
            parentConnectionDelegate?.didEndArrowAnimation(extended: false)
            
            if gridIndexOld != nil {
                cellForItem(at: IndexPath(item: gridIndexOld!, section: 0))?.clearHighlight()
                let wasImageMoved = moveImages(from: self, with: startingGridIndex, to: self, with: gridIndexOld!)
                gameViewModel.moveMade(wasImageMoved)
                parentConnectionDelegate?.didMoveAnImageOnTheGrid(withImage: wasImageMoved)
            }
        case .began, .cancelled, .failed, .possible:
            break
        }
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        startingGridIndex = indexPath.item
        collectionView.cellForItem(at: indexPath)?.highlight()
        parentConnectionDelegate?.didStartArrowAnimation(with: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.clearHighlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameViewModel.getNumberOfTiles()
    }
    
    // cell.index explained in CustomCollectionViewCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playfieldCell", for: indexPath) as? CustomCollectionViewCell else {
            fatalError("NO playfieldCell??")
        }
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        cell.index = indexPath.item
        return cell
    }
    
    // MARK: - Custom Public Mehtods
    
    // Mostly prep work cellHeight
    // Because size of sliced tiles has to be whole numbers(but still CGFloat) there will be some automatic rounding involved that results in differences between gridViewTile-size and imageTile-size
    // The edgeInsets and lineSpacing will be set depending on differenceOfPixels between grid- and image-Tiles
    func prepareGridFor(tilesPerRow: CGFloat) {
        let height = self.frame.height
        let cellHeight: CGFloat = CGFloat(Int(height / tilesPerRow))
        let differenceOfPixels = height - tilesPerRow * cellHeight
        
        let topInset: CGFloat = differenceOfPixels > 0 ? 1 : 0
        let lineSpacing = differenceOfPixels > 3 ? (differenceOfPixels - topInset) / tilesPerRow : 0
        
        layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = 0
        
        self.allowsSelection = true
        self.isScrollEnabled = false
        self.reloadData()
        self.animateAlpha()
    }
}
