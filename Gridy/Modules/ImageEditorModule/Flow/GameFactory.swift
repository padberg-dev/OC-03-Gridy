//
//  ImageEditorFactory.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class GameFactory {
    
    static func pushIn(navigator: UINavigationController, with image: UIImage) {
        
        let imageEditorController = UIStoryboard(name: "Game", bundle: nil).instantiateInitialViewController() as! ImageEditorViewController
        let gameFlowController = GameFlowController(navigator: navigator)
        let viewModel = ImageEditorVM()
        
        imageEditorController.assignDependencies(flowController: gameFlowController, image: image, viewModel: viewModel)
        
        navigator.pushViewController(imageEditorController, animated: true)
    }
}
