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
    
    @IBOutlet weak var orLoadTextYTOStackVIewConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridyButtonCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gridyPickButton: CustomButton!
    @IBOutlet weak var libraryButton: CustomButton!
    @IBOutlet weak var cameraButton: CustomButton!
    @IBOutlet weak var stackView: UIStackView!
    
    private var flow: IntroFlowController!
    private var viewModel: IntroViewModel!
    
    // MARK: - Dependency Injection
    
    func assignDependencies(flowController: IntroFlowController, viewModel: IntroViewModel) {
        self.flow = flowController
        self.viewModel = viewModel
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButtons()
    }
    
    // MARK: - Layout Change Events
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.setConstraints(isPortraitMode: isPortraitMode)
        }
    }
    
    // MARK: - Custom Methods
    
    private func setUpButtons() {
        gridyPickButton.setUpButton(withText: "Pick", andImageName: "Gridy")
        libraryButton.setUpButton(withText: "Photo Library", andImageName: "library")
        cameraButton.setUpButton(withText: "Camera", andImageName: "camera")
    }
    
    private func setConstraints(isPortraitMode: Bool) {
        gridyButtonCenterYConstraint.constant = isPortraitMode ? 0 : 100
        orLoadTextYTOStackVIewConstraint.constant = isPortraitMode ? 10 : -100
        stackView.spacing = isPortraitMode ? 30 : 480
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            moveToImageEditorVC(with: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation Controller Flow
    
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
        }
    }
}
