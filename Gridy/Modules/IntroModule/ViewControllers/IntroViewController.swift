//
//  IntroViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var gridyPickButton: CustomButton!
    @IBOutlet var libraryButton: CustomButton!
    @IBOutlet var cameraButton: CustomButton!
    
    private var flow: IntroFlowController!
    private var viewModel: IntroVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Intro View"
        setUpButtons()
    }
    
    func setUpButtons() {
        gridyPickButton.setUpButton(withText: "Pick", andImageName: "Gridy")
        libraryButton.setUpButton(withText: "Photo Library", andImageName: "library")
        cameraButton.setUpButton(withText: "Camera", andImageName: "camera")
    }
    
    func assignDependencies(flowController: IntroFlowController, viewModel: IntroVM) {
        self.flow = flowController
        self.viewModel = viewModel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            moveToNextVC(with: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func moveToNextVC(with image: UIImage) {
        flow.showImageEditor(with: image)
    }
    
    @IBAction func gridyButtonTapped(_ sender: CustomButton) {
        let imageName = viewModel.chooseRandomPhoto()
        if let image = UIImage(named: imageName) {
            moveToNextVC(with: image)
        }
    }
    
    
    @IBAction func cameraButtonTapped(_ sender: CustomButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func libraryButtonTapped(_ sender: CustomButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}
