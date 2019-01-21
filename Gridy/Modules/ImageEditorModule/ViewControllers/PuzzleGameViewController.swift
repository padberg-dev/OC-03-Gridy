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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playfieldCollectionView: PlayfieldCollectionView!
    @IBOutlet weak var playfieldGridView: CustomGridView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var checkPuzzleButton: UIButton!
    
    // MARK: - Attributes
    
    var gameViewModel: GameVM!
    var flow: GameFlowController!
    
    let topBottomInset: CGFloat = 10
    
    var imageTiles: [UIImageView] = []
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    var panGesture: UILongPressGestureRecognizer! {
        didSet {
            self.collectionView.addGestureRecognizer(panGesture)
        }
    }
    var startingPoint: CGPoint = .zero
    var startingGridIndex: Int! {
        didSet {
            if imageTiles.count > 0 {
                startingPoint = collectionView.convert(collectionView.getCenterPointOf(cell: startingGridIndex)!, to: view)
            } else {
                startingPoint = playfieldCollectionView.convert(playfieldCollectionView.getCenterPointOf(cell: startingGridIndex)!, to: view)
            }
            view.createArrow(view: &showView, from: startingPoint)
        }
    }
    var gridIndexOld: Int?
    var allowDraging: Bool = false
    
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
        if !allowDraging { return }
        
        switch panRecognizer.state {
        case .began:
            collectionView.cellForItem(at: IndexPath(item: startingGridIndex, section: 0))?.highlight()
        case .cancelled:
            break
        case .changed:
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
            showView?.animatedRemoval()
            allowDraging = false
            
            collectionView.cellForItem(at: IndexPath(item: startingGridIndex, section: 0))?.clearHighlight()
            
            if gridIndexOld != nil {
                let cell = (playfieldCollectionView.cellForItem(at: IndexPath(item: gridIndexOld!, section: 0)) as? CustomCollectionViewCell)!
                cell.clearHighlight()
                
                let wasImageMoved = view.moveImages(from: collectionView, with: startingGridIndex, to: playfieldCollectionView, with: gridIndexOld!)
                gameViewModel.moveMade(wasImageMoved)
                checkIfAllTilesOnGrid()
                
                if !cell.hasImage {
                    imageTiles.remove(at: startingGridIndex!)
                    collectionView.deleteItems(at: [IndexPath(item: startingGridIndex!, section: 0)])
                }
            }
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    // MARK: - Custom Methods
    
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
    
    private func checkIfAllTilesOnGrid() {
        if imageTiles.count == 1 {
            checkPuzzleButton.isHidden = false
            checkPuzzleButton.makeEnabled(true)
            puzzleCheck()
        }
    }
    
    private func puzzleCheck() {
        let check = checkIfPuzzleSolved()
        let color: UIColor = check ? UIColor.green : UIColor.red
        playfieldGridView.colorBorder(with: color)
        playfieldCollectionView.animateAlpha(to: 0.85, andBackTo: 1)
        
        if check {
            animateFinish()
        }
    }
    
    private func checkIfPuzzleSolved() -> Bool {
        let allCells = getCellsWithImages()
        let count = gameViewModel.getNumberOfTiles()
        
        if allCells.count == count {
            return gameViewModel.checkIfPuzzleSolved(cells: allCells)
        }
        return false
    }
    
    private func enableHintsButtons() {
        previewButton.makeEnabled(true)
        helpButton.makeEnabled(true)
        progressView.progress = 0
        progressView.alpha = 0
    }
    
    private func blockHintsButtons() {
        gameViewModel.hintUsed()
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
    
    // MARK: - Layout Change Events
    
    override func viewDidLayoutSubviews() {
        if imageTiles.count > 0 {
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .bottom)
        }
        collectionViewLayout.scrollDirection = isPortraitMode ? .horizontal : .vertical
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else {
            fatalError("NO collectionCell??")
        }
        cell.imageView.image = imageTiles[indexPath.item].image
        cell.hasImage = true
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        allowDraging = true
        startingGridIndex = indexPath.item
    }
    
    // MARK: - ConnectionDelegate
    
    func didMoveAnImageOnTheGrid(withImage: Bool) {
        if withImage, imageTiles.count == 0 {
            puzzleCheck()
        }
    }
    
    // MARK: - Custom Public Mehtods
    
    func getFirstItemPosition() -> CGPoint {
        return CGPoint(x: collectionView.frame.origin.x + collectionViewLayout.sectionInset.left, y: collectionView.frame.origin.y + topBottomInset)
    }
    
    func insertIntoCollectionView(_ imageView: UIImageView) {
        imageTiles.insert(imageView, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    func changeCellSize(to size: CGSize) {
        collectionViewLayout.itemSize = size
        playfieldCollectionView.layout.itemSize = size
        
        collectionViewHeightConstraint.constant = size.height + 2 * topBottomInset
        collectionViewWidthConstraint.constant = size.width + 2 * topBottomInset
    }
    
    func preparePlayfield() {
        playfieldCollectionView.prepareGridFor(tilesPerRow: CGFloat(gameViewModel.getNumberOfRows()))
        playfieldGridView.setNumberOf(tiles: gameViewModel.getNumberOfRows())
        containerView.animateAlpha(to: 1)
    }
    
    // MARK: - Success Animations
    
    private func animateFinish() {
        let newView = UIView(frame: view.bounds)
        newView.alpha = 0
        
        let blurView = UIVisualEffectView(frame: view.bounds)
        blurView.effect = UIBlurEffect(style: .light)
        
        newView.addSubview(blurView)
        
        let stack = UIStackView(frame: playfieldGridView.frame)
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alpha = 0
        
        newView.addSubview(stack)
        view.addSubview(newView)
        
        newView.animateAlpha(to: 1)
        
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        label.text = "YOU SOLVED THE PUZZLE"
        
        stack.addArrangedSubview(label)
        
        let label2 = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        label2.text = "With a score of \(gameViewModel.getScore())"
        
        stack.addArrangedSubview(label2)
        
        let label3 = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        label3.text = "You used hints \(gameViewModel.penalties) times"
        
        stack.addArrangedSubview(label3)
        
        stack.animateAlpha()
        stack.addArrangedSubview(newGameButton)
    }
    
    // MARK: - Action Methods
    
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        flow.newGame()
    }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        var cell: CustomCollectionViewCell!
        let imagesStillInCollectionView = imageTiles.count > 0
        
        if imagesStillInCollectionView {
            // Hint from collectionView to playfield
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
            cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CustomCollectionViewCell
        } else {
            // No more images in collectionView -> hint in Playfield
            let cellsOutOfPlace = (playfieldCollectionView.visibleCells as? [CustomCollectionViewCell])?.filter { (cell) -> Bool in
                return !gameViewModel.isCellInCorrectPlace(cell)
            }
            cell = cellsOutOfPlace?.first
        }
        
        if let image = cell?.imageView.image as? GridImage {
            startingGridIndex = imagesStillInCollectionView ? 0 : playfieldCollectionView.indexPath(for: cell)?.item
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
    
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        let newOrigin = containerView.convert(playfieldGridView.frame.origin, to: view)
        let gridFrame = CGRect(origin: newOrigin, size: playfieldGridView.frame.size)
        
        view.createPreview(of: gameViewModel.fullImage!, withGridFrame: gridFrame, isPortraitMode: isPortraitMode)
        blockHintsButtons()
    }
    
    @IBAction func checkPuzzleButtonTapped(_ sender: UIButton) {
        puzzleCheck()
    }
}
