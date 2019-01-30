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
    // ErrorView will be shown if image is out of grid. It a red view underneath grid that will be shown for a sec when image is not completely covered by grid
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var gridSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var snappingButton: UIButton!
    @IBOutlet weak var snapDegreeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var snapDegreeView: UIView!
    
    // MARK: - Dependencies
    
    var viewModel: GameVM!
    private var flow: GameFlowController!
    private var photoImage: UIImage!
    // Next ViewController's access variable
    private var gameVC: PuzzleGameViewController!
    
    // MARK: - Attributes
    
    private var bigStackView: UIStackView = UIStackView()
    // For a duration of image spliting-animation into tiles and moving those to next VC's collectionView don't allow device to rotate
    private var blockAutoration: Bool = false
    
    // User's choice for snapping to angle saved in both variables
    var isSnapingAllowed = false
    var snappingDegree = 15
    
    // MARK: - Dependency Injection
    
    func assignDependencies(flowController: GameFlowController, image: UIImage, viewModel: GameVM) {
        self.photoImage = image
        self.flow = flowController
        self.viewModel = viewModel
    }
    
    // Assigns child viewController to a variable and connects viewModels
    // ScoreLabel's and scoreDifference's refrecnces will be saved to viewModel for easier mangament of points changes
    func initializeGameVC() {
        guard let firstChild = children.first as? PuzzleGameViewController else  {
            fatalError("NO Puzzle Game View Controller??")
        }
        gameVC = firstChild
        self.gameVC.flow = flow
        self.gameVC.gameViewModel = viewModel
        self.gameVC.playfieldCollectionView.gameViewModel = viewModel
        self.gameVC.playfieldCollectionView.parentConnectionDelegate = gameVC
        
        viewModel.scoreLabel = gameVC.scoreLabel
        viewModel.scoreDifference = gameVC.scoreChangeLabel
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.rotationDelegate = self
        
        scrollView.initialize(with: photoImage)
        initializeGameVC()
        backButton.styleBackButton()
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
    
    // Resets scrollView
    // For iPad there is a separate file ImageEditorView.swift containing all constraint changes depending on portrait/landscape
    override func viewDidLayoutSubviews() {
        let gridSize = viewModel.extendInsetsToGridView ? gridView.frame.size : nil
        blurView.maskView(withHole: gridView.frame)
        scrollView.setContentSize(toFitInGrid: gridSize)
        
        resetUI()
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            (view as? ImageEditorView)?.setConstraints(isPortraitMode: isPortraitMode)
        }
    }
    
    // MARK: - Custom Methods
    
    // Changes scrollView's offsetPoint and insets
    func resetUI() {
        let offsetPoint = scrollView.contentOffset
        scrollView.changeInsets(with: scrollView.imageView.frame.origin)
        
        if viewModel.extendInsetsToGridView {
            scrollView.extendInsets(to: gridView.frame, toOffset: offsetPoint)
        }
    }
    
    private func checkIfImageOutOfGrid() -> Bool {
        // ScaleDownByHalfPoint because of rounding Problems (minimumScale is a fraction, thus view.contains will miss calculate by X < 0.5 pixels)
        let gridViewInImageViewBounds = view.convert(gridView.frame.scaleDownByHalfPoint(), to: scrollView.imageView)
        let imageViewBounds = scrollView.imageView.bounds
        
        return imageViewBounds.contains(gridViewInImageViewBounds)
    }
    
    // Check if selectButton should be enabled and if not show error label and errorView
    func checkIfCanContinue() {
        if checkIfImageOutOfGrid() {
            selectButton.makeEnabled(true)
        } else {
            selectButton.makeEnabled(false)
            errorView.animateAlpha(andBackTo: 0)
            errorLabel.animateAlpha(andBackTo: 0)
        }
    }
    
    // MARK: - Custom Animation Methods
    
    // Animate stackViews expansion to the edges
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
    
    // Moves each tile-image into collectionView one after another, but randomly chose the order of images
    // After that cleanUI
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
    
    // Finished appearance of the next VC and allow autorotation again, hide Stackview
    private func cleanUIAfterAnimation() {
        gameVC.preparePlayfield()
        blockAutoration = false
        bigStackView.isHidden = true
    }
    
    // MARK: - Navigation Controller Flow
    
    @IBAction func goBack(_ sender: UIButton) {
        flow.newGame()
    }
    
    // MARK: - Action Methods
    
    // Double check if image isn't out of grid and it isn't moving
    // Then take a snapshot of the scrollView and crops only the part covered by a grid
    // Cropped image will be sliced intro tiles and put into a stackView for animation
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        if checkIfImageOutOfGrid(), !scrollView.isDecelerating {
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
    
    // Change icon and change setting in viewModel
    // Change also the icon in the child VC
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        let isOn = viewModel.soundIsOn
        viewModel.soundIsOn = !isOn
        
        soundButton.setBackgroundImage(UIImage(named: !isOn ? "audio-on" : "audio-off"), for: .normal)
        gameVC.soundButton.setBackgroundImage(UIImage(named: !isOn ? "audio-on" : "audio-off"), for: .normal)
    }
    
    // Allow image snapping to a degree. It's in scrollView's custom rotation delegate
    // If on show next icon with numbers of degree to snap to
    @IBAction func snappingButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        snappingButton.setBackgroundImage(UIImage(named: tag == 1 ? "snapping" : "snapping-filled"), for: .normal)
        isSnapingAllowed = tag == 1 ? false : true
        
        if tag == 0 {
            snapDegreeView.animateAlpha()
            snapDegreeButton.animateAlpha()
            sender.tag = 1
        } else {
            snapDegreeView.animateAlpha(to: 0)
            snapDegreeButton.animateAlpha(to: 0)
            sender.tag = 0
        }
    }
    
    // Change the degree that the rotation will snap to. The image will also be changed
    @IBAction func snapDegreeButtonTapped(_ sender: UIButton) {
        let snapDegree = SnapDegrees(buttonTag: sender.tag)
        
        snapDegreeButton.setBackgroundImage(UIImage(named: snapDegree.imageName), for: .normal)
        snappingDegree = snapDegree.degree
        sender.tag = snapDegree.tag
    }
    
    // Rotates Image back to 0 degree
    @IBAction func resetRotationButtonTapped(_ sender: UIButton) {
        scrollView.setRotationToZero()
        angleLabel.text = "0°"
    }
    
    // Changes the number of tiles in a grid
    @IBAction func gridSliderChanged(_ sender: UISlider) {
        let sliderValue = round(sender.value)
        sender.setValue(sliderValue, animated: false)
        
        self.gridView.setNumberOf(tiles: Int(sliderValue))
    }
}
