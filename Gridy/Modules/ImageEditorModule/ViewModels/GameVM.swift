//
//  ImageEditorVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit
import AVFoundation

struct ScoreData {
    let points: Int
    let movesMade: Int
    let hintsUsed: Int
    let tiles: Int
}

struct PointsData {
    let pointsPerMove: Int
    let pointsPerPenalty: Int
    let pointsPerTile: Int
}

enum SoundTypes {
    case imageMove
    case puzzleStart
    case imageSwap
    case hint
    case finish
}

class GameVM {
    
    private(set) var fullImage: UIImage?
    private var imageTiles: [GridImage] = []
    private var tilesPerRow: Int = 0
    
    var audioPlayer: AVAudioPlayer?
    var soundIsOn = true
    
    // MARK: - Scoring Variables
    
    let timePenalty = 10.0
    
    private let pointsPerMove = -3
    private let pointsPerPenalty = -100
    private let pointsPerTile = 200
    
    private(set) var points = 0 {
        didSet {
            scoreLabel.text = String(points)
        }
    }
    private(set) var moves = 0
    private(set) var penalties = 0
    
    var scoreLabel: UILabel!
    var scoreDifference: UILabel!
    
    // MARK: - Public Settings
    
    var extendInsetsToGridView: Bool = true
    
    // MARK: - Public API's
    
    func sliceTheImage(_ image: UIImage, into tilesPerRowAndColumn: Int) {
        fullImage = image
        tilesPerRow = tilesPerRowAndColumn
        
        let step = Int(image.size.width) / tilesPerRowAndColumn
        let size = CGSize(width: step, height: step)

        for row in 0 ..< tilesPerRowAndColumn {
            for column in 0 ..< tilesPerRowAndColumn {
                let point = CGPoint(x: column * step, y: row * step)
                let rect = CGRect(origin: point, size: size)
                
                if let newTile = Utilities.cropImage(image, to: rect) {
                    let newGridImage = GridImage(cgImage: newTile.cgImage!)
                    newGridImage.row = row
                    newGridImage.column = column
                    imageTiles.append(newGridImage)
                }
            }
        }
        setInitialPoints()
        playSound(for: .puzzleStart)
    }
    
    func playSound(for type: SoundTypes) {
        if !soundIsOn { return }
        
        var soundName = ""
        switch type {
        case .imageMove:
            soundName = "glitch"
        case .puzzleStart:
            soundName = "paper"
        case .imageSwap:
            let random = Int.random(in: 0 ... 5)
            soundName = "swish\(random)"
        case .hint:
            soundName = "shotgun"
        case .finish:
            soundName = "anteUp"
        }
        play(sound: soundName)
    }
    
    func createImageStackView(ofSize size: CGRect) -> UIStackView {
        let mainStackView = UIStackView(frame: size)
        mainStackView.customizeSettings(vertical: true)
        
        let step = mainStackView.frame.height / CGFloat(tilesPerRow)
        
        for column in 0 ..< tilesPerRow {
            let rowStackView = UIStackView(frame: CGRect(x: 0, y: CGFloat(column) * step, width: size.width, height: step))
            rowStackView.customizeSettings()
            
            for row in 0 ..< tilesPerRow {
                let newImageTile = UIImageView(image: imageTiles[(column * tilesPerRow) + row])
                rowStackView.addArrangedSubview(newImageTile)
            }
            mainStackView.addArrangedSubview(rowStackView)
        }
        return mainStackView
    }
    
    // Returns a shuffled array containing numbers from 0 to numberOfTiles
    func getShuffledNumberArray() -> [Int] {
        var randomPool = Array(0 ..< getNumberOfTiles())
        randomPool.shuffle()
        return randomPool
    }
    
    func getRowAndColumn(from index: Int) -> (Int, Int) {
        let row = Int(index / tilesPerRow)
        let column = index % tilesPerRow
        
        return (row, column)
    }
    
    func getTileSize() -> CGSize {
        if imageTiles.count > 0 {
            return imageTiles[0].size
        }
        return .zero
    }
    
    func getNumberOfTiles() -> Int {
        return imageTiles.count
    }
    
    func getNumberOfRows() -> Int {
        return tilesPerRow
    }
    
    func checkIfPuzzleSolved(cells array: [CustomCollectionViewCell]) -> Bool {
        for cell in array {
            if !isCellInCorrectPlace(cell) {
                return false
            }
        }
        return true
    }
    
    func isCellInCorrectPlace(_ cell: CustomCollectionViewCell) -> Bool {
        if let image = cell.imageView.image as? GridImage {
            if cell.index == convertToIntFrom(row: image.row, column: image.column) {
                return true
            }
        }
        return false
    }
    
    func convertToIntFrom(row: Int, column: Int) -> Int {
        return tilesPerRow * row + column
    }
    
    // MARK: - Scoring Public Methods
    
    func moveMade(_ withImage: Bool) {
        if withImage {
            moves += 1
            subtractPoints(pointsPerMove)
            playSound(for: .imageSwap)
        }
    }
    
    func hintUsed() {
        penalties += 1
        subtractPoints(pointsPerPenalty)
        playSound(for: .hint)
    }
    
    func getScore() -> Int {
        return (moves - getNumberOfTiles()) * pointsPerMove + penalties * pointsPerPenalty
    }
    
    func getInjectionData() -> (ScoreData, PointsData) {
        let scoreData = ScoreData(points: points, movesMade: moves, hintsUsed: penalties, tiles: getNumberOfTiles())
        let pointsData = PointsData(pointsPerMove: pointsPerMove, pointsPerPenalty: pointsPerPenalty, pointsPerTile: pointsPerTile)
        return (scoreData, pointsData)
    }
    
    // MARK: - Private Methods
    
    private func setInitialPoints() {
        points = getNumberOfTiles() * (pointsPerTile - pointsPerMove)
    }
    
    private func updateScore() {
        points = (pointsPerTile * getNumberOfTiles()) + (moves * pointsPerMove) + (penalties * pointsPerPenalty)
    }
    
    private func subtractPoints(_ byNumber: Int) {
        scoreDifference.animateSubtraction(with: byNumber)
        updateScore()
    }
    
    private func play(sound name: String) {
        let path = Bundle.main.path(forResource: name, ofType : "mp3")!
        let url = URL(fileURLWithPath : path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}
