//
//  GameFactory.swift
//  Gridy
//
//  Created by Rafal Padberg on 20.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class GameFactory {
    
    static func pushIn(navigator: UINavigationController, with image: UIImage) {
        
        let gameViewController = UIStoryboard(name: "Game", bundle: nil).instantiateInitialViewController() as! GameViewController
        let gameFlowController = GameFlowController(navigator: navigator)
        
        gameViewController.assignDependencies(flowController: gameFlowController, image: image)
        
        navigator.pushViewController(gameViewController, animated: true)
    }
}
