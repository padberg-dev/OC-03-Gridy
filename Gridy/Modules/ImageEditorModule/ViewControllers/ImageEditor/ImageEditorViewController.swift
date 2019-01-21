//
//  ImageEditorViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: CustomScrollView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var gridView: CustomGridView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var gridSlider: UISlider!
    
    // MARK: - Dependencies
    
    private var flow: GameFlowController!
    private var viewModel: GameVM!
    private var photoImage: UIImage!
    private var gameVC: PuzzleGameViewController!
    
    // MARK: - Attributes
    
    private var bigStackView: UIStackView = UIStackView()
    private var blockAutoration: Bool = false
    
    // MARK: - Dependency Injection
    
    func assignDependencies(flowController: GameFlowController, image: UIImage, viewModel: GameVM) {
        self.photoImage = image
        self.flow = flowController
        self.viewModel = viewModel
    }
    
    // ??? W factory nie było jeszcze children
    func initializeGameVC() {
        guard let firstChild = children.first as? PuzzleGameViewController else  {
            fatalError("NO Puzzle Game View Controller??")
        }
        gameVC = firstChild
        self.gameVC.flow = flow
        self.gameVC.gameViewModel = viewModel
        self.gameVC.playfieldCollectionView.gameViewModel = viewModel
        self.gameVC.playfieldCollectionView.parentConnectionDelegate = gameVC
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.rotationDelegate = self
        
        scrollView.initialize(with: photoImage)
        initializeGameVC()
    }
    
    override var shouldAutorotate: Bool {
        return !blockAutoration
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gridView.backgroundColor = .clear
        errorView.backgroundColor = .red
        selectButton.styleSelectButton()
    }
    
    // MARK: - Layout Change Events
    
    override func viewDidLayoutSubviews() {
        let gridSize = viewModel.extendInsetsToGridView ? gridView.frame.size : nil
        blurView.maskView(withHole: gridView.frame)
        scrollView.setContentSize(toFitInGrid: gridSize)
        
        resetUI()
    }
    
    // MARK: - Custom Methods
    
    func resetUI() {
        scrollView.changeInsets(with: scrollView.imageView.frame.origin)
        
        if viewModel.extendInsetsToGridView {
            scrollView.extendInsets(to: gridView.frame)
        }
    }
    
    /// ??? ViewModel ?
    private func checkIfImageOutOfGrid() -> Bool {
        // ScaleDownByHalfPoint because of rounding Problems (minimumScale is a fraction, thus view.contains will miss calculate by X < 0.5 pixels)
        let gridViewInImageViewBounds = view.convert(gridView.frame.scaleDownByHalfPoint(), to: scrollView.imageView)
        let imageViewBounds = scrollView.imageView.bounds
        
        return imageViewBounds.contains(gridViewInImageViewBounds)
    }
    
    func checkIfCanContinue() {
        if checkIfImageOutOfGrid() {
            selectButton.isEnabled = true
            selectButton.alpha = 1
        } else {
            selectButton.isEnabled = false
            selectButton.alpha = 0.2
            errorView.animateAlpha(andBackTo: 0)
            errorLabel.animateAlpha(andBackTo: 0)
        }
    }
    
    // MARK: - Navigation Controller Flow
    
    @IBAction func goBack(_ sender: UIButton) {
        flow.newGame()
    }
    
    // MARK: - Action Methods
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        if checkIfImageOutOfGrid() {
            if let snapshotImage = Utilities.takeSnapshot(from: scrollView) {
                if let croppedImage = Utilities.cropImage(snapshotImage, to: gridView.frame) {
                    
                    viewModel.sliceTheImage(croppedImage, into: gridView.getNumberOfTiles())
                    gameVC.changeCellSize(to: viewModel.getTileSize())
                    
                    view.hideNotNeededUI()
                    bigStackView = viewModel.createImageStackView(ofSize: gridView.frame)
                    view.addSubview(bigStackView)
                    animateStackViews()
                    moveContainerViewIntoScreen()
                    blockAutoration = true
                }
            }
        }
    }
    
    // ??? Stepper
    @IBAction func gridSliderChanged(_ sender: UISlider) {
        let sliderValue = round(sender.value)
        sender.setValue(sliderValue, animated: false)
        
        self.gridView.setNumberOf(tiles: Int(sliderValue))
    }
    
    // MARK: - Custom Animation Methods
    
    private func animateStackViews() {
        let gridOrigin = gridView.frame.origin
        let spaceToExtend = (isPortraitMode ? gridOrigin.x : gridOrigin.y) - 5
        
        bigStackView.animateSlicing(in: view, to: gridOrigin, extendBy: spaceToExtend)
    }
    
    private func moveContainerViewIntoScreen() {
        containerView.prepareForSlidingIn(portraitMode: isPortraitMode, to: view.bounds)
        
        UIView.animate(withDuration: 0.8, animations: {
            self.containerView.frame.origin = CGPoint(x: 0, y: 0)
        }) { [weak self] _ in
            self?.moveImageTiles(into: (self?.gameVC.getFirstItemPosition())!)
        }
    }
    
    private func moveImageTiles(into position: CGPoint) {
        var randomPool = viewModel.getShuffledNumberArray()
        let numberOfTiles = randomPool.count
        
        for i in 0 ..< numberOfTiles {
            let number = randomPool.remove(at: 0)
            let (row, _) = viewModel.getRowAndColumn(from: number)
            
            let tileImageView = bigStackView.getRandomImageViewFromInsideStackView(row)
            let newView = view.createNewView(from: tileImageView!)

            view.addSubview(newView)
            
            UIView.animate(withDuration: 0.35, delay: 0.04 * Double(i), options: UIView.AnimationOptions.curveEaseInOut, animations: {
                newView.frame.origin = position
            }, completion: { [weak self] _ in
                newView.isHidden = true
                self?.gameVC.insertIntoCollectionView((newView.subviews[0] as? UIImageView)!)
                
                if i == numberOfTiles - 1 {
                    self?.cleanUIAfterAnimation()
                }
            })
        }
    }
    
    private func cleanUIAfterAnimation() {
        gameVC.preparePlayfield()
        blockAutoration = false
        bigStackView.isHidden = true
        
        view.removeTransparentViews()
    }
}
