//
//  GameViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 20.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var flow: GameFlowController!
    var puzzleImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = puzzleImage
    }
    
    func assignDependencies(flowController: GameFlowController, image: UIImage) {
        self.flow = flowController
        self.puzzleImage = image
    }
    
    @IBAction func goBack() {
        flow.goBack()
    }
}
