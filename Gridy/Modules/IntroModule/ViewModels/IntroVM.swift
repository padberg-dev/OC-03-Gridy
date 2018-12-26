//
//  IntroVM.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import Foundation

class IntroVM {
    
    private let photosNames = [
        "office", "puppy", "lion", "eiffel", "pizza"
    ]
    
    func chooseRandomPhoto() -> String {
        return "eiffel"
        return photosNames.randomElement()!
    }
}
