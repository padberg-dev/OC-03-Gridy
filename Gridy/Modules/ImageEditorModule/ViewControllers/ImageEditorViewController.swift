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
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var gridSlider: UISlider!
    
    private var flow: ImageEditorFlowController!
    private var viewModel: ImageEditorVM!
    
    private var gameVC: PuzzleGameViewController!
//
//    lazy private var bigStackView: UIStackView = {
//        let stackView = UIStackView(frame: gridView.frame)
//        stackView.customizeSettings(vertical: true)
//        return stackView
//    }()
    
    private var bigStackView: UIStackView = UIStackView()
    
    var photoImage: UIImage!
    var extendInsetsToGridView: Bool = false
    
    var isPortraitMode: Bool {
        get {
            let bounds = UIScreen.main.bounds
            return bounds.height > bounds.width
        }
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.rotationDelegate = self
        
        extendInsetsToGridView = false
        
        scrollView.initialize(with: photoImage)
        
        guard let firstChild = children.first as? PuzzleGameViewController else  {
            fatalError("NO Puzzle Game View Controller??")
        }
        gameVC = firstChild
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
        let gridViewInImageViewBounds = view.convert(gridView.frame, to: scrollView.imageView)
        let imageViewBounds = scrollView.imageView.bounds
        
        if imageViewBounds.contains(gridViewInImageViewBounds) {
            if let snapshotImage = takeSnapshot(from: scrollView) {
                if let croppedImage = Utilities.cropImage(snapshotImage, to: gridView.frame) {
                    viewModel.sliceTheImage(croppedImage, into: gridView.getNumberOfTiles())
                    
                    hideAllUI()
                    createStackViews(from: viewModel.getImageArray(), with: gridView.getNumberOfTiles())
                    animateStackViews()
                    
                    callGameContainer()
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
    
    // MARK: - Custom Animation Methods
    
    private func hideAllUI() {
        UIView.animate(withDuration: 0.6) {
            self.view.subviews.forEach { (view) in
                view.alpha = view.isHidden ? 1 : 0
            }
        }
        
    }
    
    private func getRidOfHiddenUI() {
        self.view.subviews.forEach { (view) in
            if view.alpha == 0 {
                view.removeFromSuperview()
            }
        }
    }
    
    private func createStackViews(from photoSlices: [UIImage], with numberOfTilesPerRow: Int) {
        bigStackView = UIStackView(frame: gridView.frame)
        bigStackView.customizeSettings(vertical: true)
        
        let step = bigStackView.frame.height / CGFloat(numberOfTilesPerRow)
        
        for column in 0 ..< numberOfTilesPerRow {
            let rowStackView = UIStackView(frame: CGRect(x: 0, y: CGFloat(column) * step, width: gridView.frame.width, height: step))
            rowStackView.customizeSettings()
            
            for row in 0 ..< numberOfTilesPerRow {
                let newImageTile = UIImageView(image: photoSlices[(column * 5) + row])
                rowStackView.addArrangedSubview(newImageTile)
            }
            bigStackView.addArrangedSubview(rowStackView)
        }
        
        view.addSubview(bigStackView)
    }
    
    private func animateStackViews() {
        let gridOrigin = gridView.frame.origin
        let step = (isPortraitMode ? gridOrigin.x : gridOrigin.y) - 5
        let number = gridView.getNumberOfTiles()
        
        UIView.animate(withDuration: 0.8, animations: {
            
        }) { [weak self] _ in
            self?.bigStackView.frame.size = CGSize(
                width: (self?.bigStackView.frame.width)! + 2 * step,
                height: (self?.bigStackView.frame.height)! + 2 * step
            )
            
            UIView.animate(withDuration: 0.8, animations: {
                self?.view.layoutIfNeeded()
                self?.bigStackView.frame.origin.x -= step
                self?.bigStackView.frame.origin.y -= step
                self?.bigStackView.spacing = (2 * step) / CGFloat(number - 1)
                self?.bigStackView.subviews.forEach({ (innerStackView) in
                    (innerStackView as! UIStackView).spacing = (2 * step) / CGFloat(number - 1)
                })
            })
        }
    }
    
    private func callGameContainer() {
        if isPortraitMode {
            containerView.frame.origin.x = 2 * view.bounds.width
        } else {
            containerView.frame.origin.y = -2 * view.bounds.height
        }
        containerView.isHidden = false
        
        UIView.animate(withDuration: 0.8, animations: {
            self.containerView.frame.origin.x = 0
            self.containerView.frame.origin.y = 0
        }) { [weak self] _ in
            self?.moveImageTiles(into: (self?.gameVC.collectionView.frame.origin)!)
        }
    }
    
    private func moveImageTiles(into position: CGPoint) {
        let numberOfTilesPerRow = gridView.getNumberOfTiles()
        let numberOfTiles = numberOfTilesPerRow * numberOfTilesPerRow
        
        var randomPool = Array(0 ..< numberOfTiles)
        randomPool.shuffle()
        
        for i in 0 ..< numberOfTiles {
            let number = randomPool.remove(at: 0)
            let (row, _) = getPosition(ofTile: number, inRectangleWith: numberOfTilesPerRow)
            
            let rowStackView = self.bigStackView.subviews[row] as? UIStackView
            let numberOfSubviews = rowStackView?.subviews.count
            let tileImageView = rowStackView?.subviews[Int.random(in: 0 ..< numberOfSubviews!)]
            
            let oldFrame = CGRect(origin: CGPoint(x: bigStackView.frame.origin.x + tileImageView!.frame.origin.x,
                                                  y: bigStackView.frame.origin.y + rowStackView!.frame.origin.y),
                                  size: tileImageView!.frame.size
            )
            
            rowStackView?.removeArrangedSubview(tileImageView!)
            tileImageView?.removeFromSuperview()
            
            print(oldFrame)
            
            let newView = UIView(frame: oldFrame)
            newView.addSubview(tileImageView!)
            
            tileImageView?.frame.origin = oldFrame.origin
            
            view.addSubview(newView)
            
            print(newView)
            
            UIView.animate(withDuration: 0.4, delay: 0.025 * Double(i), options: UIView.AnimationOptions.curveEaseInOut, animations: {
                newView.frame.origin = position
//                newView.alpha = 0.0
            }, completion: { _ in
                newView.isHidden = true
            })
        }
        bigStackView.isHidden = true
        getRidOfHiddenUI()
    }
    
    private func getPosition(ofTile number: Int, inRectangleWith numberOfTilesPerRow: Int) -> (Int, Int) {
        let row = Int(number / numberOfTilesPerRow)
        let column = number % numberOfTilesPerRow
        
        return (row, column)
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
