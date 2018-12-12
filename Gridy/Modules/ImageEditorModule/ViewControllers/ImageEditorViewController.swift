//
//  ImageEditorViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var photoImage: UIImage!
    
    private var flow: ImageEditorFlowController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Image Editor View"
        imageView.image = photoImage
    }
    
    func assignDependencies(flowController: ImageEditorFlowController, image: UIImage) {
        self.flow = flowController
        self.photoImage = image
    }
}
