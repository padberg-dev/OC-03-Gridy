//
//  ImageEditorFactory.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorFactory {
    
    static func pushIn(navigator: UINavigationController, with image: UIImage) {
        
        let imageEditorController = UIStoryboard(name: "ImageEditor", bundle: nil).instantiateInitialViewController() as! ImageEditorViewController
        let imageEditorFlowController = ImageEditorFlowController(navigator: navigator)
        let viewModel = ImageEditorVM()
        
        imageEditorController.assignDependencies(flowController: imageEditorFlowController, image: image, viewModel: viewModel)
        
        navigator.pushViewController(imageEditorController, animated: true)
    }
}
