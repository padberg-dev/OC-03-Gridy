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
        navigationController.isNavigationBarHidden = true
        
        let introViewController = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController() as! IntroViewController
        let introFlowController = IntroFlowController(navigator: navigationController)
        let introViewModel = IntroViewModel()
        
        introViewController.assignDependencies(flowController: introFlowController, viewModel: introViewModel)
        navigationController.setViewControllers([introViewController], animated: false)
        
        window.rootViewController = navigationController
    }
}
