//
//  ImageEditorViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK:- Outlets and Attributes
    
    @IBOutlet var scrollView: CustomScrollView! {
        didSet {
            let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateView(byReactingTo:)))
            scrollView.addGestureRecognizer(rotationRecognizer)
        }
    }
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var gridView: UIView!
    
    private var flow: ImageEditorFlowController!
    
    var photoImage: UIImage!
    
    // MARK:- View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.initialize(with: photoImage)
        
        createMaskedBlurView()
    }
    
    // MARK:- Layout Change Events
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        print("********* new Size")
        print(size)
    }
    
    // MARK:- Private 
    
    func createMaskedBlurView() {
        blurView.layer.mask = nil
        
        let maskLayer = CAShapeLayer()
        
        let topInset = UIApplication.shared.statusBarFrame.height
        
        maskLayer.frame = view.bounds
        
        let path = UIBezierPath(rect: view.bounds)
        
        let rectIncludingInsets = CGRect(origin: CGPoint(x: gridView.frame.minX, y: gridView.frame.minY - topInset), size: gridView.frame.size)
        
        path.append(UIBezierPath(rect: rectIncludingInsets))
        
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        
        blurView.layer.mask = maskLayer
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
//    func getIt() -> UIView {
//        return scrollView.imageView
//    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return (scrollView as! CustomScrollView).imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    // MARK:- Navigation Controller Flow
    
    func assignDependencies(flowController: ImageEditorFlowController, image: UIImage) {
        self.flow = flowController
        self.photoImage = image
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        flow.goBack()
    }
    
    @IBAction func crop(_ sender: UIButton) {
//        print("IMAGE-frame: \(imageView.frame)")
//        print("IMAGE-bounds: \(imageView.bounds)")
//        print("SCROLL-frame: \(scrollView.frame)")
//        print("SCROLL-bounds: \(scrollView.bounds)")
//        print("SCROLL-ContentSize: \(scrollView.contentSize)")
//        print("OFFSET: \(scrollView.contentOffset)")
//        print("**********************")
    }
    
    @objc func rotateView(byReactingTo rotationRecognizer: UIRotationGestureRecognizer) {
        
//        let rotation = rotationRecognizer.rotation
////        rotationRecognizer.rotation = 0
//
//        let transform = CGAffineTransform(rotationAngle: rotation)
//        imageView.transform = transform
//
//        let newZeroPoint = imageView.frame.origin
//        let newSize = imageView.frame.size
//        scrollView.contentInset = UIEdgeInsets(top: -newZeroPoint.y, left: -newZeroPoint.x, bottom: 0, right: 0)
//
//        scrollView.contentSize = CGSize(width: newSize.width + newZeroPoint.x, height: newSize.height + newZeroPoint.y)
    }
    
    @IBAction func moveBounds() {
        print("--> MOVE BOUNDS")
    }
    
    func getImage(from contextView: UIView, in cropFrame: CGRect) -> (UIImage?, CGImage?) {
        
        UIGraphicsBeginImageContext(CGSize(width: contextView.frame.size.width,
                                           height: contextView.frame.size.height))
        contextView.drawHierarchy(in: CGRect(x: contextView.frame.origin.x,
                                             y: contextView.frame.origin.y,
                                             width: contextView.frame.size.width,
                                             height: contextView.frame.size.height),
                                  afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {return (nil, nil)}
        UIGraphicsEndImageContext()
        
        guard let croppedImage = image.cgImage?.cropping(to: cropFrame) else {return (image, nil)}
        return (image, croppedImage)
    }
}



/*
 func calculateImageView() {
 let photoSize = photoImage.size
 let screenSize = UIScreen.main.bounds
 
 let photoRatio = photoSize.width / photoSize.height
 let screenRatio = screenSize.width / screenSize.height
 
 print("\(photoRatio) - \(screenRatio)")
 
 if photoRatio > screenRatio {
 ((biggerRatio / smallerRatio) - 1) * smallerWidth = WIDTH-DIFFERENCE ON SAME RATIO
 print("INCREASE WIDTH")
 
 let widthIncrease = ((photoRatio / screenRatio) - 1) * screenSize.width
 
 centerYConstraint.constant = 0
 centerXConstraint.constant = widthIncrease / 2
 } else {
 ((biggerRatio / smallerRatio) - 1) * smallerHeight = HEIGHT-DIFFERENCE ON SAME RATIO
 print("INCREASE HEIGHT")
 
 let heightIncrease = ((screenRatio / photoRatio) - 1) * screenSize.height
 
 centerYConstraint.constant = heightIncrease / 2
 centerXConstraint.constant = 0
 }
 } */
