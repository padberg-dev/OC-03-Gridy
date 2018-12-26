//
//  ImageEditorFlow.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorFlowController {
    
    let navigator: UINavigationController
    
    init(navigator: UINavigationController) {
        self.navigator = navigator
    }
    
    func goBack() {
        navigator.popViewController(animated: true)
    }
    
    func showGameView(with image: UIImage) {
        GameFactory.pushIn(navigator: navigator, with: image)
    }
}
