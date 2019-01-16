//
//  IntroViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets and Attributes
    
    @IBOutlet var gridyPickButton: CustomButton!
    @IBOutlet var libraryButton: CustomButton!
    @IBOutlet var cameraButton: CustomButton!
    
    @IBOutlet var haha: UIView!
    
    private var flow: IntroFlowController!
    private var viewModel: IntroViewModel!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButtons()
    }
    
    // MARK: - Custom Methods
    
    private func setUpButtons() {
        gridyPickButton.setUpButton(withText: "Pick", andImageName: "Gridy")
        libraryButton.setUpButton(withText: "Photo Library", andImageName: "library")
        cameraButton.setUpButton(withText: "Camera", andImageName: "camera")
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("GO")
            moveToImageEditorVC(with: selectedImage)
        }
        print("DISMISS")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation Controller Flow
    
    func assignDependencies(flowController: IntroFlowController, viewModel: IntroViewModel) {
        self.flow = flowController
        self.viewModel = viewModel
    }
    
    private func moveToImageEditorVC(with image: UIImage) {
        flow.showImageEditor(with: image)
    }
    
    // MARK: - Action Methods
    
    @IBAction func gridyButtonTapped(_ sender: CustomButton) {
        let imageName = viewModel.chooseRandomPhoto()
        if let image = UIImage(named: imageName) {
            moveToImageEditorVC(with: image)
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
        } else {
            print("DENIED")
        }
    }
}
