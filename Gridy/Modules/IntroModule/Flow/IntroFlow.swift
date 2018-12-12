//
//  IntroFlow.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class IntroFlowController {
    
    let navigator: UINavigationController
    
    init(navigator: UINavigationController) {
        self.navigator = navigator
    }
    
    func showImageEditor(with image: UIImage) {
        ImageEditorFactory.pushIn(navigator: navigator, with: image)
    }
}
