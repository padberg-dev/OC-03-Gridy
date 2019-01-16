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
    
    // MARK: - Attributes
    
    var viewModel: ImageEditorVM!
    var flow: GameFlowController!
    
    let topBottomInset: CGFloat = 10
    
    var imageTiles: [UIImageView] = []
    var collectionViewLayout: UICollectionViewFlowLayout!
    
//    var startingPoint: CGPoint = .zero
//    var showView: ArrowView?
    var movingImageIndex: IndexPath?
//    var lastItemIndex: IndexPath?
//
//    var panGesture: UIPanGestureRecognizer! {
//        didSet {
//            self.view.addGestureRecognizer(panGesture)
//        }
//    }
    
    // ------------
    
    var panGesture: UIPanGestureRecognizer! {
        didSet {
            self.view.addGestureRecognizer(panGesture)
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
    
    var showView: ArrowView?
    
        private func killArrowView() {
            UIView.animate(withDuration: 0.3, animations: {
                self.showView?.alpha = 0
            }) { [weak self] _ in
                self?.showView?.removeFromSuperview()
                self?.showView = nil
            }
        }
    // ------
    
    @objc func handlePan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            break
        case .cancelled:
            break
        case .changed:
            let movePoint = panRecognizer.location(in: view)
            showView?.resizeFrameFrom(startPoint: startingPoint, toPoint: movePoint)
            
            if gridIndexOld != nil { playfieldCollectionView.cellFromItem(gridIndexOld!)?.clearHighlight() }
            
            if let index = playfieldCollectionView.getGridItem(of: movePoint) {
                playfieldCollectionView.cellFromItem(index)?.highlight()
                gridIndexOld = index
            } else {
                gridIndexOld = nil
            }
        case .ended:
            killArrowView()
            
            if gridIndexOld != nil {
                playfieldCollectionView.cellFromItem(gridIndexOld!)?.clearHighlight()
                print("MOVE")
                view.moveImages(from: collectionView, with: startingGridIndex, to: playfieldCollectionView, with: gridIndexOld!)
            }
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    // MARK: - Gesture Recognizer
    /*
    @objc func handlePan(byReactingTo gestureRecognizer: UIPanGestureRecognizer) {
        if allowDraging || isDraging {
            switch gestureRecognizer.state {
            case .began:
                print("BEGAN")
                allowDraging = false
                isDraging = true
                
                startingPoint = gestureRecognizer.location(in: view)
                print(startingPoint)
                
                if showView == nil {
                    showView = ArrowView(frame: CGRect(origin: startingPoint, size: .zero))
                    showView?.contentMode = .redraw
                    showView?.backgroundColor = .clear
                    view.addSubview(showView!)
                }
                collectionView.isScrollEnabled = false
            case .cancelled:
                print("CANCELLED")
            case .changed:
                let movePoint = gestureRecognizer.location(in: view)
                let differencePoint = CGPoint(x: movePoint.x - startingPoint.x, y: movePoint.y - startingPoint.y)
                
                showView?.frame.size = CGSize(width: abs(differencePoint.x), height: abs(differencePoint.y))
                let negX = differencePoint.x < 0
                let negY = differencePoint.y < 0
                
                showView?.negativeX = negX
                showView?.negativeY = negY
                if negX { showView?.frame.origin.x = movePoint.x }
                if negY { showView?.frame.origin.y = movePoint.y }
                
                
                let point = gestureRecognizer.location(in: playfieldCollectionView)
                let index = playfieldCollectionView.indexPathForItem(at: point)
                if index?.item != nil {
                    
                    if lastItemIndex != index && lastItemIndex != nil {
                        print("YES")
                        let cell = playfieldCollectionView.cellForItem(at: lastItemIndex!)
                        cell!.alpha = 1
                    }
                    
                    let cell = playfieldCollectionView.cellForItem(at: index!)
                    cell?.alpha = 0.5
                    lastItemIndex = index
                }
            case .ended:
                print("ENDED")
                allowDraging = false
                isDraging = false
                
                let point = gestureRecognizer.location(in: playfieldCollectionView)
                print(point)
                
                let index = playfieldCollectionView.indexPathForItem(at: point)
                
                (view.subviews.last)?.removeFromSuperview()
                showView = nil
                
                if index != nil && movingImageIndex != nil {
//                    movePicture(with: index!, and: movingImageIndex!)
                    view.moveImages(from: collectionView, with: (index?.item)!, to: playfieldCollectionView, with: (movingImageIndex?.item)!)
                }
                collectionView.isScrollEnabled = true
                
                movingImageIndex = nil
            case .failed:
                print("FAILED")
            case . possible:
                print("POSIBLE")
            }
        }
    }
    **/
    
    @objc func handlePlayfieldPan(byReactingTo gestureRecognizer: UIPanGestureRecognizer) {
        
    }
    /*
    private func movePicture(with indexPath: IndexPath, and oldIndex: IndexPath) {
        let oldCell = collectionView.cellForItem(at: oldIndex) as? CustomCollectionViewCell
        let newCell = playfieldCollectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell
        newCell?.alpha = 1
        
        let hasImage = newCell?.hasImage
        
        print(hasImage)
        
        let startPoint = collectionView.convert(oldCell!.frame.origin, to: view)
        let endPoint = playfieldCollectionView.convert(newCell!.frame.origin, to: view)
        
        let newImage = imageTiles.remove(at: movingImageIndex!.item)
        collectionView.deleteItems(at: [movingImageIndex!])
        collectionView.reloadData()
        
        let oldImage = hasImage! ? UIImageView(image: newCell?.imageView.image!) : nil
        
        let newImageView = UIView(frame: CGRect(origin: startPoint, size: oldCell!.frame.size))
        newImageView.addSubview(newImage)
        view.addSubview(newImageView)
        
        let oldImageView = UIView(frame: CGRect(origin: endPoint, size: newCell!.frame.size))
        
        if hasImage! {
            oldImageView.addSubview(oldImage!)
            view.addSubview(oldImageView)
        }
        
        UIView.animate(withDuration: 0.6, animations: {
            newImageView.frame.origin = endPoint

            if hasImage! {
                oldImageView.frame.origin = startPoint
            }
        }) { [weak self] _ in
            newCell?.imageView.image = newImage.image
            newCell?.hasImage = true

            if hasImage! {
                self?.imageTiles.insert(oldImage!, at: oldIndex.item)
                self?.collectionView.insertItems(at: [oldIndex])

                oldImageView.removeFromSuperview()
            }
            newImageView.removeFromSuperview()
        }
    }
    */
    var allowDraging: Bool = false
    var isDraging: Bool = false
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StyleGuide.greenLight
        setUpCollectionViews()
        setUpGestureRecognizers()
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
        
        collectionView.isUserInteractionEnabled = false
        allowDraging = true
        
//        ??
        startingGridIndex = indexPath.item
        
        movingImageIndex = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        
        collectionView.isUserInteractionEnabled = true
        allowDraging = false
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
        playfieldGridView.animateAlpha(toValue: 0.4)
    }
    
    // MARK: - Action Methods
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        flow.goBack()
    }
    
    @IBAction func checkPuzzle(_ sender: UIButton) {
        let allCells = playfieldCollectionView.visibleCells.filter { (cell) -> Bool in
            if let image = ((cell as? CustomCollectionViewCell)?.imageView.image) as? GridImage {
                if image.row != nil {
                    return true
                }
            }
            return false
        }
        let count = viewModel.getNumberOfTiles()
        
        if allCells.count == count {
            if let cells = allCells as? [CustomCollectionViewCell] {
                print(viewModel.checkIfPuzzleSolved(cells: cells))
            }
        }
    }
}
