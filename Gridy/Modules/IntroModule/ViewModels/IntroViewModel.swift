//
//  IntroVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import Foundation

class IntroViewModel {
    
    private let photosNames = [
        "office", "puppy", "lion", "eiffel", "pizza"
    ]
    
    // MARK: - Public API
    
    func chooseRandomPhoto() -> String {
        return photosNames.randomElement()!
    }
}
