//
//  PlayfieldCollectionView.swift
//  Gridy
//
//  Created by Rafal Padberg on 06.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PlayfieldCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var layout: UICollectionViewFlowLayout!
    var numberOfTiles: Int = 0
    var panGesture: UIPanGestureRecognizer! {
        didSet {
            self.addGestureRecognizer(panGesture)
        }
    }
    var startingPoint: CGPoint = .zero
    var startingGridIndex: Int! {
        didSet {
            startingPoint = getMiddlePointOf(cell: startingGridIndex)!
            createArrow(view: &showView, from: startingPoint)
        }
    }
    var gridIndexOld: Int?
    
    var showView: ArrowView?
    
    // MARK: - Gesture Recognizer Methods
    
    @objc func handlePan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            break
        case .cancelled:
            break
        case .changed:
            let movePoint = panRecognizer.location(in: self)
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: movePoint)
            
            if gridIndexOld != nil { cellFromItem(gridIndexOld!)?.clearHighlight() }
            
            if let index = self.getGridItem(of: movePoint) {
                cellFromItem(index)?.highlight()
                gridIndexOld = index
            } else {
                gridIndexOld = nil
            }
        case .ended:
            killArrowView()
            
            if gridIndexOld != nil {
                cellFromItem(gridIndexOld!)?.clearHighlight()
                print("MOVE")
                moveImages(from: self, with: startingGridIndex, to: self, with: gridIndexOld!)
            }
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    // MARK: Custom Methods
    
//    private func createArrowView() {
//        if showView == nil {
//            showView = ArrowView(frame: CGRect(origin: startingPoint, size: .zero))
//            self.addSubview(showView!)
//        }
//    }
    
    private func killArrowView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.showView?.alpha = 0
        }) { [weak self] _ in
            self?.showView?.removeFromSuperview()
            self?.showView = nil
        }
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.highlight()
        
        startingGridIndex = indexPath.item
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
