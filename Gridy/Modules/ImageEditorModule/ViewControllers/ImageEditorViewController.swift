//
//  ImageEditorViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController {
    
    // MARK: - Outlets and Attributes
    
    @IBOutlet var scrollView: CustomScrollView!    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var gridView: CustomGridView!
    @IBOutlet var errorView: UIView!
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var gridSlider: UISlider!
    
    private var flow: ImageEditorFlowController!
    private var viewModel: ImageEditorVM!
    
    var photoImage: UIImage!
    var extendInsetsToGridView: Bool = false
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.rotationDelegate = self
        
        extendInsetsToGridView = false
        
        scrollView.initialize(with: photoImage)
    }
    
    // FIX: Add DispatchQueue
    override func viewWillAppear(_ animated: Bool) {
        gridView.backgroundColor = .clear
        errorView.backgroundColor = .red
        selectButton.styleSelectButton()
    }
    
    // MARK: - Layout Change Events
    
    override func viewDidLayoutSubviews() {
        maskBlurView()
        scrollView.setContentSize()
    }
    
    // MARK: - Custom Methods
    
    private func maskBlurView() {
        let maskLayer = CAShapeLayer()
        // REMOVE?
        // let topInset = UIApplication.shared.statusBarFrame.height
        
        maskLayer.frame = view.bounds
        
        let path = UIBezierPath(rect: view.bounds)
        // let rectIncludingInsets = CGRect(origin: CGPoint(x: gridView.frame.minX, y: gridView.frame.minY - topInset), size: gridView.frame.size)
        
        path.append(UIBezierPath(rect: gridView.frame))
        
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        
        blurView.layer.mask = maskLayer
    }
    
    private func changeInsets(of scrollView: UIScrollView, byOriginOf view: UIView, scaledBy scale: CGFloat) {
        let oldOffset = scrollView.contentOffset
        let newZeroPoint = view.frame.origin
        
        scrollView.contentInset = UIEdgeInsets(top: -newZeroPoint.y, left: -newZeroPoint.x, bottom: -newZeroPoint.y, right: -newZeroPoint.x)
        scrollView.contentInset.rescaleBy(scale)
        
        scrollView.contentOffset = oldOffset
        
        if extendInsetsToGridView {
            extendInsets(of: scrollView, to: gridView.frame)
        }
    }
    
    private func extendInsets(of scrollView: UIScrollView, to frame: CGRect) {
        // FIXME: Remove? topInset not needed?
        // let topInset = UIApplication.shared.statusBarFrame.height
        
        let leftMargin = frame.minX
        let topMargin = frame.minY
        let rightMargin = scrollView.frame.width - frame.maxX
        let bottomMargin = scrollView.frame.height - frame.maxY
        
        scrollView.contentInset.left += leftMargin
        scrollView.contentInset.top += topMargin
        scrollView.contentInset.right += rightMargin
        scrollView.contentInset.bottom += bottomMargin
    }
    
    
    private func getEdgePoint(from rect: CGRect) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        // FIXME: Remove? method not needed?
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let BottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let BottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        return (topLeft, topRight, BottomLeft, BottomRight)
    }
    
    private func takeSnapshot(from contextView: UIView) -> UIImage? {
        var newImage: UIImage?
        
        UIGraphicsBeginImageContext(contextView.frame.size)
        contextView.drawHierarchy(in: contextView.frame, afterScreenUpdates: true)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            newImage = image
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - Navigation Controller Flow
    
    func assignDependencies(flowController: ImageEditorFlowController, image: UIImage, viewModel: ImageEditorVM) {
        self.flow = flowController
        self.photoImage = image
        self.viewModel = viewModel
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        flow.goBack()
    }
    
    // MARK: - Action Methods
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        print(scrollView.contentOffset)
        
        let gridViewInImageViewBounds = view.convert(gridView.frame, to: scrollView.imageView)
        let imageViewBounds = scrollView.imageView.bounds
        
        if imageViewBounds.contains(gridViewInImageViewBounds) {
            if let snapshotImage = takeSnapshot(from: scrollView) {
                if let croppedImage = Utilities.cropImage(snapshotImage, to: gridView.frame) {
                    viewModel.sliceTheImage(croppedImage, into: gridView.getNumberOfTiles())
                    
                    
                }
            }
        } else {
            errorView.animateError()
        }
    }
    
    @IBAction func gridSliderChanged(_ sender: UISlider) {
        let sliderValue = round(sender.value)
        sender.setValue(sliderValue, animated: false)
        
        self.gridView.setNumberOf(tiles: Int(sliderValue))
    }
    
    func goToNext() {
//        let (first, second) = getImage(from: scrollView, in: gridView.frame)
//        
//        let imageSlices = sliceTheImage(second!)
//        createAnimation(with: imageSlices)
//        flow.showGameView(with: imageSlices[2])
    }
    
    func createAnimation(with imageArray: [UIImage]) {
        let bigStackView = UIStackView(frame: gridView.frame)
        bigStackView.axis = .vertical
        bigStackView.spacing = 0
        bigStackView.distribution = .fillEqually
        bigStackView.alignment = .fill
        
        let step = bigStackView.frame.height / 5
        
        for i in 0 ..< 5 {
            let newStackView = UIStackView(frame: CGRect(
                x: 0,
                y: (CGFloat(i) * step),
                width: gridView.frame.width,
                height: step)
            )
            newStackView.axis = .horizontal
            newStackView.alignment = .fill
            newStackView.distribution = .fillEqually
            for j in 0 ..< 5 {
                let image = UIImageView(image: imageArray[(i * 5) + j])
                newStackView.addArrangedSubview(image)
            }
            newStackView.spacing = 0
            bigStackView.addArrangedSubview(newStackView)
        }
        
        view.addSubview(bigStackView)
        bigStackView.subviews.forEach { (stackView) in
            print(stackView.frame)
            stackView.subviews.forEach({ (image) in
                print(image.frame)
            })
        }
        errorView.isHidden = true
        gridView.isHidden = true
        
        UIView.animate(withDuration: 0.8, animations: {
            self.blurView.alpha = 0
            self.scrollView.alpha = 0
        }) { [weak self] _ in
            
            let step = (self?.gridView.frame.origin.x)! - 5
            
            bigStackView.frame.size = CGSize(width: bigStackView.frame.width + 2 * step, height: bigStackView.frame.height + 2 * step)
            
            UIView.animate(withDuration: 0.8, animations: {
                self?.view.layoutIfNeeded()
                bigStackView.frame.origin.x -= step
                bigStackView.frame.origin.y -= step
                bigStackView.spacing = (2 * step) / 8
                bigStackView.subviews.forEach({ (innerStackView) in
                    (innerStackView as! UIStackView).spacing = (2 * step) / 8
                })
            })
        }
        
    }
    
    func sliceTheImage(_ image: CGImage) -> [UIImage] {
        var imageArray: [UIImage] = []
        
        let width = image.width
        
        let step = width / 5
        let size = CGSize(width: step, height: step)
        
        for i in 0 ..< 5 {
            for j in 0 ..< 5 {
                let point = CGPoint(x: j * step, y: i * step)
                let rect = CGRect(origin: point, size: size)
                let newSlice = image.cropping(to: rect)
                imageArray.append(UIImage(cgImage: newSlice!))
            }
        }
        return imageArray
    }
    
    @IBAction func moveBounds() {
        
    }
}

extension ImageEditorViewController: UIScrollViewDelegate {

    // MARK: - UIScrollViewDelegate Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.contentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        changeInsets(of: scrollView, byOriginOf: self.scrollView.imageView, scaledBy: scale)
    }
}

extension ImageEditorViewController: CustomScrollViewRotationDelegate {
    
    // MARK: - CustomScrollViewRotationDelegate Methods

    func viewForRotation(in scrollView: CustomScrollView) -> UIView? {
        return scrollView.imageView
    }
    
    func scrollViewIsRotating(_ scrollView: CustomScrollView, view: UIView, by radiants: CGFloat) {
        let transform = CGAffineTransform(rotationAngle: radiants)
        
        view.transform = transform
    }
    
    func scrollViewDidEndRotation(_ scrollView: CustomScrollView, with view: UIView, rotatedBy radiants: CGFloat) {
        changeInsets(of: scrollView, byOriginOf: view, scaledBy: scrollView.zoomScale)
    }
    
    func scrollView(_ scrollView: CustomScrollView, rotationSnapsToAngle inAngularDegrees: CGFloat) -> CGFloat {
        return 0
    }
    
    func scrollView(_ scrollVIew: CustomScrollView, cummulativeRotation isSet: Bool) -> Bool {
        return true
    }
}
