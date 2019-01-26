//
//  PuzzleGameViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PuzzleGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ParentConnectionDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    // Collection View with all images
    @IBOutlet weak var collectionView: UICollectionView!
    // Collection View with a grid
    @IBOutlet weak var playfieldCollectionView: PlayfieldCollectionView!
    @IBOutlet weak var playfieldGridView: CustomGridView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var checkPuzzleButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreChangeLabel: UILabel!
    
    // MARK: - Attributes
    
    // A view with detailed score after completing puzzle
    var successView: SuccessView?
    
    var gameViewModel: GameVM!
    var flow: GameFlowController!
    
    // Insets for collectionView
    let topBottomInset: CGFloat = 10
    
    var imageTiles: [UIImageView] = []
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    var panGesture: UILongPressGestureRecognizer! {
        didSet {
            self.collectionView.addGestureRecognizer(panGesture)
        }
    }
    // Starting point for the arrow
    var startingPoint: CGPoint = .zero
    // Index of collectionView cell
    // After it gets passed by a gesture recognizer or helpBUttonTapped(_:) the centerPoint of the chosen cell will be assigned to startingPoint
    var startingGridIndex: Int! {
        didSet {
            startingPoint = collectionView.convert(collectionView.getCenterPointOf(cell: startingGridIndex)!, to: view)
            view.createArrow(view: &showView, from: startingPoint)
        }
    }
    // Index of playfieldCollectionView cell. Rest same as above
    var startingGridIndexPlayfield: Int! {
        didSet {
            startingPoint = playfieldCollectionView.convert(playfieldCollectionView.getCenterPointOf(cell: startingGridIndexPlayfield)!, to: view)
            view.createArrow(view: &showView, from: startingPoint)
        }
    }
    // Index of the cell over which the arrow is dragging
    // If let go it becomes the endCell for image swap
    var gridIndexOld: Int?
    
    var showView: ArrowView?
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StyleGuide.greenLight
        containerView.alpha = 0
        
        setUpCollectionViews()
        setUpGestureRecognizers()
        styleButtons()
        progressView.style()
    }
    
    // MARK: - Gesture Recognizer
    
    @objc private func handlePan(byReactingTo panRecognizer: UILongPressGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            collectionView.cellForItem(at: IndexPath(item: startingGridIndex, section: 0))?.highlight()
        case .cancelled:
            break
        case .changed:
            // Converts location of pan to playfieldCollectionView
            // Resize Arrow
            // Clear highlight on old cell and highligh new cell if convertedLocation over a playfield cell
            let movePoint = panRecognizer.location(in: view)
            let movePointConverted = view.convert(movePoint, to: playfieldCollectionView)
            
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: movePoint)
            
            if gridIndexOld != nil { playfieldCollectionView.cellForItem(at: IndexPath(item: gridIndexOld!, section: 0))?.clearHighlight() }
            
            if let index = playfieldCollectionView.getGridItem(of: movePointConverted) {
                playfieldCollectionView.cellForItem(at: IndexPath(item: index, section: 0))?.highlight()
                gridIndexOld = index
            } else {
                gridIndexOld = nil
            }
        case .ended:
            // Make arrow disappear and clear highlights
            // If pan ended over playfieldCollectionView move images
            // Remove chosen image from imageTiles and from collectionView
            // Then check if all tiles are on playfield grid
            showView?.animatedRemoval()
            
            collectionView.cellForItem(at: IndexPath(item: startingGridIndex, section: 0))?.clearHighlight()
            
            if gridIndexOld != nil {
                let cell = (playfieldCollectionView.cellForItem(at: IndexPath(item: gridIndexOld!, section: 0)) as? CustomCollectionViewCell)!
                cell.clearHighlight()
                
                let wasImageMoved = view.moveImages(from: collectionView, with: startingGridIndex, to: playfieldCollectionView, with: gridIndexOld!)
                gameViewModel.moveMade(wasImageMoved)
                
                imageTiles.remove(at: startingGridIndex!)
                collectionView.deleteItems(at: [IndexPath(item: startingGridIndex!, section: 0)])
                checkIfAllTilesOnGrid()
            }
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    // MARK: - Custom Methods
    
    // Set delegates, round corners, set up layout insets
    private func setUpCollectionViews() {
        playfieldCollectionView.delegate = playfieldCollectionView
        playfieldCollectionView.dataSource = playfieldCollectionView
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.roundCorners(by: topBottomInset)
        
        collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        playfieldCollectionView.layout = playfieldCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // Assign gesture recognizer to variables
    private func setUpGestureRecognizers() {
        panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(byReactingTo:)))
        panGesture.minimumPressDuration = 0.3
        
        playfieldCollectionView.panGesture = UIPanGestureRecognizer(target: playfieldCollectionView, action: #selector(handlePan(byReactingTo:)))
    }
    
    private func styleButtons() {
        newGameButton.styleSelectButton()
        previewButton.styleSelectButton()
        checkPuzzleButton.styleSelectButton()
        helpButton.styleSelectButton()
    }
    
    // Returns an array of all cells from playfieldCollectionView that have an image
    private func getCellsWithImages() -> [CustomCollectionViewCell] {
        let allCells = playfieldCollectionView.visibleCells.filter { (cell) -> Bool in
            if let image = ((cell as? CustomCollectionViewCell)?.imageView.image) as? GridImage {
                if image.row != nil {
                    return true
                }
            }
            return false
        }
        return (allCells as? [CustomCollectionViewCell]) ?? []
    }
    
    // If all images are on the playfield show checkButton and check if puzzle are solved
    private func checkIfAllTilesOnGrid() {
        if imageTiles.count == 0 {
            checkPuzzleButton.isHidden = false
            checkPuzzleButton.makeEnabled(true)
            puzzleCheck()
        }
    }
    
    // Check happens before image swap -> delay check by swap animation time
    // Change border color of the playfield accordingly for a sec
    // If puzzle is solved fire finish animation
    private func puzzleCheck(immediately: Bool = false) {
        let delay = immediately ? 0 : 0.4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let check = self.checkIfPuzzleSolved()
            let color: UIColor = check ? UIColor.green : UIColor.red
            
            self.playfieldGridView.colorBorder(with: color.withAlphaComponent(0.3))
            
            if check {
                self.animateFinish()
            }
        }
    }
    
    // If all cells have images check if they are in the right place return boolean answer
    private func checkIfPuzzleSolved() -> Bool {
        let allCells = getCellsWithImages()
        let count = gameViewModel.getNumberOfTiles()
        
        if allCells.count == count {
            return gameViewModel.checkIfPuzzleSolved(cells: allCells)
        }
        return false
    }
    
    // Inform gameVM of hint usage and block hints for timePenalty duration and shows progress bar
    // After this time allow hints buttons again
    private func blockHintsButtons() {
        self.gameViewModel.hintUsed()
        previewButton.makeEnabled(false)
        helpButton.makeEnabled(false)
        progressView.alpha = 1
        
        let duration = gameViewModel.timePenalty
        UIView.animate(withDuration: duration) {
            self.progressView.setProgress(1, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.9) {
            self.enableHintsButtons()
        }
    }
    
    // Makes hint buttons enables again, hides progress bar
    private func enableHintsButtons() {
        previewButton.makeEnabled(true)
        helpButton.makeEnabled(true)
        progressView.progress = 0
        progressView.alpha = 0
    }
    
    // MARK: - Layout Change Events
    
    // ScrollDirection didn't always changed on orientation change, it has something to do with scrolling collectionView
    // Make collectionView stop scrolling by selecting first item without animation
    // Also iPad constraint changes
    override func viewDidLayoutSubviews() {
        if imageTiles.count > 0 {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: isPortraitMode ? .bottom : .left)
        }
        collectionViewLayout.scrollDirection = isPortraitMode ? .horizontal : .vertical
        if successView != nil {
            successView?.frame = view.frame
        }
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            (view as? PuzzleGameView)?.setConstraints(isPortraitMode: isPortraitMode)
            successView?.setConstraints(isPortraitMode: isPortraitMode)
        }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTiles.count
    }
    
    // Assign images to each cell and make customCell's attribute hasImage true
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else {
            fatalError("NO collectionCell??")
        }
        cell.imageView.image = imageTiles[indexPath.item].image
        cell.hasImage = true
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods {
    
    // Start arrow animation on highlight.
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        startingGridIndex = indexPath.item
    }
    
    // MARK: - ConnectionDelegate
    
    // Reason for this is to check if puzzle is solved from inside of playfield -> child parent connection
    func didMoveAnImageOnTheGrid(withImage: Bool) {
        if withImage, imageTiles.count == 0 {
            puzzleCheck()
        }
    }
    
    // All delegates methods below are made for the purpose of allowing the arrowView to be drawn in this parentView not inside of playfield
    func didStartArrowAnimation(with index: Int) {
        startingGridIndexPlayfield = index
    }
    
    func shouldResizeArrowFrame(to point: CGPoint) {
        let convertedPoint = playfieldCollectionView.convert(point, to: view)
        showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: convertedPoint)
    }
    
    func didEndArrowAnimation(extended: Bool = false) {
        showView?.animatedRemoval(extendedDuration: extended)
    }
    
    // MARK: - Custom Public Mehtods
    
    // For animation of tiles into collectionView
    func getFirstItemPosition() -> CGPoint {
        return CGPoint(x: collectionView.frame.origin.x + collectionViewLayout.sectionInset.left, y: collectionView.frame.origin.y + topBottomInset)
    }
    
    func insertIntoCollectionView(_ imageView: UIImageView) {
        imageTiles.insert(imageView, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    // Resize collectionView according to slliced tile size
    func changeCellSize(to size: CGSize) {
        collectionViewLayout.itemSize = size
        playfieldCollectionView.layout.itemSize = size
        
        collectionViewHeightConstraint.constant = size.height + 2 * topBottomInset
        collectionViewWidthConstraint.constant = size.width + 2 * topBottomInset
    }
    
    // Prepare grid and animate alpha
    func preparePlayfield() {
        playfieldCollectionView.prepareGridFor(tilesPerRow: CGFloat(gameViewModel.getNumberOfRows()))
        playfieldGridView.setNumberOf(tiles: gameViewModel.getNumberOfRows())
        containerView.animateAlpha(to: 1)
    }
    
    // MARK: - Success Animations
    
    // Show SuccesView, pass game data to it and play a sound
    private func animateFinish() {
        successView = SuccessView(frame: view.frame)
        successView?.initialize()
        
        let (scoreData, pointsData) = gameViewModel.getInjectionData()
        successView?.injectData(score: scoreData, points: pointsData)
        successView?.conectFlowController(flow: flow)
        
        view.addSubview(successView!)
        
        successView?.animateSuccess()
        
        gameViewModel.playSound(for: .finish)
    }
    
    // MARK: - Action Methods
    
    // Change icon and change setting in viewModel
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        let isOn = gameViewModel.soundIsOn
        gameViewModel.soundIsOn = !isOn
        
        soundButton.setBackgroundImage(UIImage(named: !isOn ? "audio-on" : "audio-off"), for: .normal)
    }
    
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        flow.newGame()
    }
    
    // Show a right move with an arrow
    // Default is to show an image from collectionView to its right position on the playfield
    // If collectionView is empty take all cells from playfield and filter all cells that are not in correct position and take the first one
    // Show an arrow from its current to its correct position
    // Block hints buttons after that
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        var cell: CustomCollectionViewCell!
        let imagesStillInCollectionView = imageTiles.count > 0
        
        if imagesStillInCollectionView {
            // Hint from collectionView to playfield
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
            cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CustomCollectionViewCell
        } else {
            // No more images in collectionView -> hint in Playfield
            let cells = getCellsWithImages()
            let cellsOutOfPlace = cells.filter { (cell) -> Bool in
                return !gameViewModel.isCellInCorrectPlace(cell)
            }
            cell = cellsOutOfPlace.first
        }
        
        if let image = cell?.imageView.image as? GridImage {
            if imagesStillInCollectionView {
                startingGridIndex = 0
            } else {
                startingGridIndexPlayfield = playfieldCollectionView.indexPath(for: cell)?.item
            }
            let endCellIndex = gameViewModel.convertToIntFrom(row: image.row!, column: image.column!)
            let endPoint = playfieldCollectionView.getCenterPointOf(cell: endCellIndex)
            let convertedPoint = playfieldCollectionView.convert(endPoint!, to: view)
            showView?.alpha = 0
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: convertedPoint)
            showView?.animateAlpha()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.showView?.animatedRemoval()
        }
        blockHintsButtons()
    }
    
    // Create a preview with full image for a couple of sec after that block hints
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        let newOrigin = containerView.convert(playfieldGridView.frame.origin, to: view)
        let gridFrame = CGRect(origin: newOrigin, size: playfieldGridView.frame.size)
        
        view.createPreview(of: gameViewModel.fullImage!, withGridFrame: gridFrame, isPortraitMode: isPortraitMode, above: scoreLabel)
        blockHintsButtons()
    }
    
    // Now there is no animation involved so do it immediately
    @IBAction func checkPuzzleButtonTapped(_ sender: UIButton) {
        puzzleCheck(immediately: true)
    }
}
