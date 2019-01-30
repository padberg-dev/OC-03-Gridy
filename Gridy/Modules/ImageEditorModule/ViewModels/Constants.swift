//
//  Constants.swift
//  Gridy
//
//  Created by Rafal Padberg on 30.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import Foundation

struct SnapDegrees {
    var tag = 0
    var degree = 0
    var imageName = ""
    
    init(buttonTag: Int) {
        self.tag = buttonTag + 1
        
        switch self.tag {
            case 1:
            degree = 30
            case 2:
            degree = 45
            case 3:
            degree = 90
            default:
            self.tag = 0
            degree = 15
        }
        self.imageName = String(degree)
    }
}

struct SuccessViewData {
    var descriptions: [String] = []
    var pointsPerX: [String] = []
    var calculations: [String] = []
    var endScore: String = ""
    
    init(score: ScoreData, points: PointsData) {
        descriptions.append("\(score.tiles) tiles")
        descriptions.append("Min. \(score.tiles) moves")
        descriptions.append("\(score.movesMade) moves made")
        descriptions.append("\(score.hintsUsed) hints used")
        
        pointsPerX.append("\(points.pointsPerTile)")
        pointsPerX.append("\(-points.pointsPerMove)")
        pointsPerX.append("\(points.pointsPerMove)")
        pointsPerX.append("\(points.pointsPerPenalty)")
        
        calculations.append("\(points.pointsPerTile * score.tiles)")
        calculations.append("\(-points.pointsPerMove * score.tiles)")
        calculations.append("\(points.pointsPerMove * score.movesMade)")
        calculations.append("\(points.pointsPerPenalty * score.hintsUsed)")
        
        self.endScore = "\(score.points)"
    }
}
