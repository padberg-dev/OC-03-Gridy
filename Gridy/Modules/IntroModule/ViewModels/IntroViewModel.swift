//
//  IntroVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import Foundation

class IntroViewModel {
    
    // Array of images names in xcassets file
    private let photosNames = [
        "office", "puppy", "lion", "eiffel", "pizza"
    ]
    
    // Unit Test FailCase
//    private let photosNames = ["noName", ""]
    
    // MARK: - Public API
    
    func chooseRandomPhoto() -> String {
        return photosNames.randomElement() ?? ""
    }
}
