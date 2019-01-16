//
//  PuzzleGameViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PuzzleGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playfieldCollectionView: PlayfieldCollectionView!
    @IBOutlet weak var playfieldGridView: CustomGridView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var checkPuzzleButton: UIButton!
    
    // MARK: - Attributes
    
    var viewModel: ImageEditorVM!
    var flow: GameFlowController!
    
    let topBottomInset: CGFloat = 10
    
    var imageTiles: [UIImageView] = []
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    var panGesture: UIPanGestureRecognizer! {
        didSet {
            self.collectionView.addGestureRecognizer(panGesture)
        }
    }
    var startingPoint: CGPoint = .zero
    var startingGridIndex: Int! {
        didSet {
            startingPoint = collectionView.convert(collectionView.getMiddlePointOf(cell: startingGridIndex)!, to: view)
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
        setUpCollectionViews()
        setUpGestureRecognizers()
        styleButtons()
    }
    
    // MARK: - Gesture Recognizer
    
    @objc private func handlePan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        if !allowDraging { return }
        
        switch panRecognizer.state {
        case .began:
            break
        case .cancelled:
            break
        case .changed:
            let movePoint = panRecognizer.location(in: view)
            let movePointConverted = view.convert(movePoint, to: playfieldCollectionView)
            
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: movePoint)
            
            if gridIndexOld != nil { playfieldCollectionView.cellFromItem(gridIndexOld!)?.clearHighlight() }
            
            if let index = playfieldCollectionView.getGridItem(of: movePointConverted) {
                playfieldCollectionView.cellFromItem(index)?.highlight()
                gridIndexOld = index
            } else {
                gridIndexOld = nil
            }
        case .ended:
            showView?.kill()
            allowDraging = false
            
            if gridIndexOld != nil {
                let cell = (playfieldCollectionView.cellFromItem(gridIndexOld!) as? CustomCollectionViewCell)!
                cell.clearHighlight()
                
                view.moveImages(from: collectionView, with: startingGridIndex, to: playfieldCollectionView, with: gridIndexOld!)
                
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
        
        collectionView.allowsSelection = true
        collectionView.roundEdges(by: topBottomInset)
        
        collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        playfieldCollectionView.layout = playfieldCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func setUpGestureRecognizers() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(byReactingTo:)))
        
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
    
    private func checkIfPuzzleSolved() -> Bool {
        let allCells = getCellsWithImages()
        let count = viewModel.getNumberOfTiles()
        
        if allCells.count == count {
            return viewModel.checkIfPuzzleSolved(cells: allCells)
        }
        return false
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
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.highlight()
        
        allowDraging = true
        startingGridIndex = indexPath.item
        
        collectionView.isUserInteractionEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        
        collectionView.isUserInteractionEnabled = true
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
        playfieldCollectionView.prepareGridFor(tilesPerRow: CGFloat(viewModel.getNumberOfRows()))
        playfieldGridView.setNumberOf(tiles: viewModel.getNumberOfRows())
        containerView.animateAlpha(toValue: 1)
    }
    
    // MARK: - Action Methods
    
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        flow.newGame()
    }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        let cells = getCellsWithImages()
        if cells.count > 1 {
            if viewModel.checkIfPuzzleSolved(cells: cells) {
                
            }
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
        let cell = collectionView.cellFromItem(0) as? CustomCollectionViewCell
        if let image = cell?.imageView.image as? GridImage {
            
            let endCellIndex = viewModel.convertToIntFrom(row: image.row!, column: image.column!)
            startingGridIndex = 0
            let endPoint = playfieldCollectionView.getMiddlePointOf(cell: endCellIndex)
            let convertedPoint = playfieldCollectionView.convert(endPoint!, to: view)
            showView?.alpha = 0
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: convertedPoint)
            showView?.animateAlpha()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showView?.kill()
        }
    }
    
    // TUTAJ JESZCZE NIE SKOŃCZONE
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        let newView = UIView(frame: playfieldGridView.frame.extendAllSidesBy(25))
        newView.backgroundColor = StyleGuide.yellowLight
        newView.roundEdges(by: 15)
        
        containerView.addSubview(newView)
        
        let stackView = viewModel.createImageStackView(ofSize: CGRect(origin: CGPoint(x: 25, y: 25), size: playfieldGridView.frame.size))
        newView.addSubview(stackView)
        
        let progressBar = UIProgressView(frame: CGRect(origin: CGPoint(x: 25, y: 20), size: CGSize(width: stackView.frame.width, height: 2)))
        progressBar.trackTintColor = .clear
        progressBar.tintColor = StyleGuide.navy
        newView.addSubview(progressBar)
        
        UIView.animate(withDuration: 2.0) {
            progressBar.setProgress(1, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            newView.removeFromSuperview()
        }
    }
    
    @IBAction func checkPuzzleButtonTapped(_ sender: UIButton) {
        let color: UIColor = checkIfPuzzleSolved() ? UIColor.green : UIColor.red
        
        view.backgroundColor = color
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.backgroundColor = StyleGuide.greenLight
        }
    }
}
