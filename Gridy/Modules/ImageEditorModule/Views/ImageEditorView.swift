//
//  ImageEditorView.swift
//  Gridy
//
//  Created by Rafal Padberg on 24.01.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class ImageEditorView: UIView {

    @IBOutlet weak var gridViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberOfRowsTextTOBackYConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfRowsTextTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var gridSliderTOnumberOfRowsYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var angleLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var angleLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var angleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var angleLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var soundButtonCenterYTOResetButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonCenterXTOResetButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonTopTOResetButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonLeadingTOGridViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonBottomTOGridViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonTopConsraint: NSLayoutConstraint!
    @IBOutlet weak var soundButtonTrailingTOGridViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var resetButtonCenterXTOGridViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var snappingButtonTrailingTOGridViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonTopTOGridView: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonBottomTOGridView: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonLeadingTOGridView: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonCenterYTOsnapDegreeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonCenterXTOsnapDegreeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonTopTOsnapDegreeButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var snappingButtonLeadingTOsnapDegreeButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectButtonCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButtonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectButtonLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorLabelBottomTOSelectButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabelBottomConstraint: NSLayoutConstraint!
    
    func setConstraints(isPortraitMode: Bool) {
        gridViewLeadingConstraint.isActive = isPortraitMode
        gridViewCenterYConstraint.isActive = isPortraitMode
        gridViewTopConstraint.isActive = !isPortraitMode
        gridViewBottomConstraint.isActive = !isPortraitMode

        numberOfRowsTextTOBackYConstraint.isActive = isPortraitMode
        numberOfRowsTextTopConstraint.isActive = !isPortraitMode

        gridSliderTOnumberOfRowsYConstraint.constant = isPortraitMode ? 20 : 5

        angleLabelTopConstraint.isActive = isPortraitMode
        angleLabelLeadingConstraint.isActive = !isPortraitMode
        angleLabelCenterXConstraint.isActive = isPortraitMode
        angleLabelCenterYConstraint.isActive = !isPortraitMode

        soundButtonTrailingTOGridViewConstraint.isActive = !isPortraitMode
        soundButtonCenterYTOResetButtonConstraint.isActive = isPortraitMode
        soundButtonCenterXTOResetButtonConstraint.isActive = !isPortraitMode
        soundButtonTopTOResetButtonConstraint.isActive = !isPortraitMode
        soundButtonTopConsraint.isActive = isPortraitMode
        soundButtonBottomTOGridViewConstraint.isActive = !isPortraitMode
        soundButtonLeadingTOGridViewConstraint.isActive = isPortraitMode

        resetButtonCenterXTOGridViewConstraint.isActive = isPortraitMode

        snappingButtonTopTOGridView.isActive = isPortraitMode
        snappingButtonTrailingTOGridViewConstraint.isActive = isPortraitMode
        snappingButtonCenterYTOsnapDegreeButtonConstraint.isActive = isPortraitMode
        snappingButtonLeadingTOsnapDegreeButtonConstraint.isActive = isPortraitMode
        snappingButtonCenterXTOsnapDegreeButtonConstraint.isActive = !isPortraitMode
        snappingButtonTopTOsnapDegreeButtonConstraint.isActive = !isPortraitMode
        snappingButtonLeadingTOGridView.isActive = !isPortraitMode
        snappingButtonBottomTOGridView.isActive = !isPortraitMode

        selectButtonCenterXConstraint.isActive = isPortraitMode
        selectButtonBottomConstraint.isActive = isPortraitMode
        selectButtonCenterYConstraint.isActive = !isPortraitMode
        selectButtonLeadingConstraint.isActive = !isPortraitMode

        errorLabelBottomConstraint.isActive = !isPortraitMode
        errorLabelBottomTOSelectButtonConstraint.isActive = isPortraitMode
        
        self.layoutIfNeeded()
    }
    
    
}
