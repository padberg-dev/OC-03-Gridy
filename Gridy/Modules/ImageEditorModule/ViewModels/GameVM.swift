//
//  ImageEditorVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 27.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit
import AVFoundation

// Structs will be used for data passing, and enums for sound clarification
// Arrays or ints could be used for this purpose as well but that would be very unclear
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
    
    // MARK: - Scoring Variables
    
    // A user gets fixed ammount of points on start and each move that he makes make score less.
    // So in order to have a good score one have to make less moves to complete a puzzle
    // Depending on number of tiles different inital points will be set
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
    var soundIsOn = true
    
    // MARK: - Public API's
    
    // Takes an image and crops it into given ammount of square tiles peer column with same number of rows
    // Then the initial points will be set and sound played
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
    
    // Play sound only if the user didn't disabled it
    // Change the name of the needed audio file depending on type of event that is happening
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
    
    // Creates and returns a stackView with stackViews inside, that will have tiles inside them
    // It should look like a full image
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
    
    // For example index 13 in 5x5 grid would be row= 3 and column=4
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
    
    // Check if all of the cells are in correct position
    func checkIfPuzzleSolved(cells array: [CustomCollectionViewCell]) -> Bool {
        for cell in array {
            if !isCellInCorrectPlace(cell) {
                return false
            }
        }
        return true
    }
    
    // Check if index of the cell equals the converted index from image row- and columnValue
    func isCellInCorrectPlace(_ cell: CustomCollectionViewCell) -> Bool {
        if let image = cell.imageView.image as? GridImage {
            if cell.index == convertToIntFrom(row: image.row, column: image.column) {
                return true
            }
        }
        return false
    }
    
    // For example: Row 3 and Column 4 in 5x5 grid would give index of 13
    func convertToIntFrom(row: Int, column: Int) -> Int {
        return tilesPerRow * row + column
    }
    
    // MARK: - Scoring Public Methods
    
    // If a move was made with at least one image add +1 move, play sound and subtract points
    func moveMade(_ withImage: Bool) {
        if withImage {
            moves += 1
            subtractPoints(pointsPerMove)
            playSound(for: .imageSwap)
        }
    }
    
    // Play sound, subtract penalty from score and add penalties += 1
    func hintUsed() {
        penalties += 1
        subtractPoints(pointsPerPenalty)
        playSound(for: .hint)
    }
    
    // Calculate score and return it
    func getScore() -> Int {
        return (moves - getNumberOfTiles()) * pointsPerMove + penalties * pointsPerPenalty
    }
    
    // Format all the score and points data into structs and return them
    func getInjectionData() -> SuccessViewData {
        let scoreData = ScoreData(points: points, movesMade: moves, hintsUsed: penalties, tiles: getNumberOfTiles())
        let pointsData = PointsData(pointsPerMove: pointsPerMove, pointsPerPenalty: pointsPerPenalty, pointsPerTile: pointsPerTile)
        return SuccessViewData(score: scoreData, points: pointsData)
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
    
    // Plays a file with a given name
    // Aysnc dispatch so that loading the sound doesn't block main thread
    private func play(sound name: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = Bundle.main.path(forResource: name, ofType : "mp3")!
            let url = URL(fileURLWithPath : path)
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.play()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
