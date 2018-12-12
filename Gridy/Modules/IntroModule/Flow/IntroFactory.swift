//
//  IntroFactory.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class IntroFactory {
    
    static func showIn(window: UIWindow) {
        
        let navigationController = UINavigationController()
        
        let introController = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController() as! IntroViewController
        let introFlowController = IntroFlowController(navigator: navigationController)
        let introViewModel = IntroVM()
        
        introController.assignDependencies(flowController: introFlowController, viewModel: introViewModel)
        
        navigationController.setViewControllers([introController], animated: false)
        
        window.rootViewController = navigationController
    }
}
