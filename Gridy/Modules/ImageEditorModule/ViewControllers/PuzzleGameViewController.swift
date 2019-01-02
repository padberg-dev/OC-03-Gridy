//
//  PuzzleGameViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PuzzleGameViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StyleGuide.greenLight
    }
}
