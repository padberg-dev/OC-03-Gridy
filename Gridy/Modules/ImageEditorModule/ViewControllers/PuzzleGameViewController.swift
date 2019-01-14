//
//  PuzzleGameViewController.swift
//  Gridy
//
//  Created by Rafal Padberg on 02.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class PuzzleGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - Outlets and Attributes
    
    var viewModel: ImageEditorVM!
    var flow: GameFlowController!
    
    let topBottomInset: CGFloat = 10
    var imageTiles: [UIImageView] = []
    var collectionViewLayout: UICollectionViewFlowLayout!
    var playfieldCollectionViewLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var playfieldCollectionView: PlayfieldCollectionView!
    @IBOutlet weak var playfieldGridView: CustomGridView!
    
    var panGesture: UIPanGestureRecognizer?
    var playfieldPanGesture: UIPanGestureRecognizer?
    
    var startingPoint: CGPoint = .zero
    var showView: ArrowView?
    var movingImageIndex: IndexPath?
    var lastItemIndex: IndexPath?
    
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
                    movePicture(with: index!, and: movingImageIndex!)
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
    
    var startingGridIndex: Int?
    var gridItemOld: Int?
    
    private func getGridItem(of point: CGPoint) -> Int? {
        let index = playfieldCollectionView.indexPathForItem(at: point)
        if let id = index?.item {
            return id
        }
        return nil
    }
    
    @objc func handlePlayfieldPan(byReactingTo gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            print("BEGAN")
            print("SECOND-PAN")
            
            startingPoint = gestureRecognizer.location(in: view)
            let startingItem = gestureRecognizer.location(in: playfieldCollectionView)
            print(startingPoint)
            
            startingGridIndex = getGridItem(of: startingItem)
            print("S: \(startingGridIndex)")
            
            if showView == nil {
                showView = ArrowView(frame: CGRect(origin: startingPoint, size: .zero))
                showView?.contentMode = .redraw
                showView?.backgroundColor = .clear
                view.addSubview(showView!)
            }
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
            if let index = getGridItem(of: point) {
                
                if gridItemOld != index && gridItemOld != nil {
                    let cell = playfieldCollectionView.cellForItem(at: IndexPath(item: gridItemOld!, section: 0))
                    cell!.alpha = 1
                }
                let cell = playfieldCollectionView.cellForItem(at: IndexPath(item: index, section: 0))
                cell?.alpha = 0.5
                gridItemOld = index
            }
        case .ended:
            print("ENDED SECOND-PAN")
            
            let point = gestureRecognizer.location(in: playfieldCollectionView)
            print(point)
            
            (view.subviews.last)?.removeFromSuperview()
            showView = nil
            
            if gridItemOld != nil,  startingGridIndex != nil {
                print("MOVE BOTH")
                movePicture2(with: gridItemOld!, and: startingGridIndex!)
            }
            
            movingImageIndex = nil
        case .failed:
            print("FAILED")
        case . possible:
            print("POSIBLE")
        }
    }
    
    private func movePicture2(with index: Int, and startIndex: Int) {
        let startCell = playfieldCollectionView.cellForItem(at: IndexPath(item: startIndex, section: 0)) as? CustomCollectionViewCell
        let endCell = playfieldCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CustomCollectionViewCell
        endCell?.alpha = 1
        
        let imageSize = startCell?.frame.size
        
        let startHasImage = startCell?.hasImage
        let endHasImage = endCell?.hasImage
        print("START HAS: \(startHasImage), END HAS: \(endHasImage)")
        
        let startPoint = playfieldCollectionView.convert(startCell!.frame.origin, to: view)
        let endPoint = playfieldCollectionView.convert(endCell!.frame.origin, to: view)
        
        let startImage = startHasImage! ? UIImageView(image: startCell?.imageView.image!) : nil
        let endImage = endHasImage! ? UIImageView(image: endCell?.imageView.image!) : nil
        
        let startImageView = UIView(frame: CGRect(origin: startPoint, size: imageSize!))
        let endImageView = UIView(frame: CGRect(origin: endPoint, size: imageSize!))
        
        if startHasImage! {
            startImageView.addSubview(startImage!)
            view.addSubview(startImageView)
            
            startCell?.imageView.image = nil
        }
        
        if endHasImage! {
            endImageView.addSubview(endImage!)
            view.addSubview(endImageView)
            
            endCell?.imageView.image = nil
        }
        
        UIView.animate(withDuration: 0.6, animations: {
            if endHasImage! {
                endImageView.frame.origin = startPoint
            } else {
                
            }
            if startHasImage! {
                startImageView.frame.origin = endPoint
            }
        }) { [weak self] _ in
            if endHasImage! {
                startCell?.imageView.image = endImage?.image
                endImageView.removeFromSuperview()
            }
            if startHasImage! {
                endCell?.imageView.image = startImage?.image
                startImageView.removeFromSuperview()
            }
            startCell?.hasImage = endHasImage ?? false
            endCell?.hasImage = startHasImage ?? false
        }
    }
    
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
    
    var allowDraging: Bool = false
    var isDraging: Bool = false
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StyleGuide.greenLight
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        playfieldCollectionView.delegate = playfieldCollectionView
        playfieldCollectionView.dataSource = playfieldCollectionView
        
        collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        playfieldCollectionViewLayout = playfieldCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(byReactingTo:)))
        self.view.addGestureRecognizer(panGesture!)
        
        
        playfieldPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePlayfieldPan(byReactingTo:)))
        self.playfieldCollectionView.addGestureRecognizer(playfieldPanGesture!)
    }
    
    func prepareGrid() {
        playfieldCollectionViewLayout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        playfieldCollectionViewLayout.minimumLineSpacing = 0
        playfieldCollectionViewLayout.minimumInteritemSpacing = 0
        
        playfieldCollectionView.numberOfTiles = viewModel.getNumberOfTiles()
        playfieldCollectionView.allowsSelection = true
        
        playfieldGridView.setNumberOf(tiles: viewModel.getNumberOfRows())
        playfieldCollectionView.isScrollEnabled = false
        
        playfieldCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.8, animations: { [weak self] in
            self?.playfieldCollectionView.alpha = 1
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.4, animations: {
                self?.playfieldGridView.alpha = 0.4
            })
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
        if collectionView.tag == 1 {
            print("Number of tiles = \(viewModel.getNumberOfTiles())")
            return viewModel.getNumberOfTiles()
        }
        return imageTiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell
            if imageTiles.count > indexPath.item {
                cell?.imageView.image = imageTiles[indexPath.item].image
            }
            cell?.backgroundColor = .blue
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playfieldCell", for: indexPath)
            cell.backgroundColor = .blue
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = StyleGuide.greenDark.cgColor
        
        collectionView.isScrollEnabled = false
        allowDraging = true
        
        movingImageIndex = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = StyleGuide.greenDark.cgColor
        
        collectionView.isScrollEnabled = true
        allowDraging = false
    }
    
    // MARK: - Custom Public Mehtods
    
    func getFirstItemPosition() -> CGPoint {
        return CGPoint(x: collectionView.frame.origin.x + collectionViewLayout.sectionInset.left,
                       y: collectionView.frame.origin.y + topBottomInset)
    }
    
    func insert(_ imageView: UIImageView) {
        imageTiles.insert(imageView, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    func changeCellSize(to size: CGSize) {
        collectionViewLayout.itemSize = size
        playfieldCollectionViewLayout.itemSize = size
        
        collectionViewHeightConstraint.constant = size.height + 2 * topBottomInset
        collectionViewWidthConstraint.constant = size.width + 2 * topBottomInset
        collectionView.reloadData()
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
