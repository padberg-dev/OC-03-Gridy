//
//  PlayfieldCollectionView.swift
//  Gridy
//
//  Created by Rafal Padberg on 06.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PlayfieldCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var numberOfTiles: Int = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTiles
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playfieldCell", for: indexPath) as? CustomCollectionViewCell
        cell?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        cell?.index = indexPath.item
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = StyleGuide.greenDark.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = StyleGuide.greenDark.cgColor
    }
}
