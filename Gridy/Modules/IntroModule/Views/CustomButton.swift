//
//  CustomButton.swift
//  Gridy
//
//  Created by Rafal Padberg on 12.12.18.
//  Copyright © 2018 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    @IBOutlet weak var customBigLabel: UILabel!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customTextLabel: UILabel!
    
    override func awakeFromNib() {
        self.backgroundColor = .clear
        self.titleLabel?.text = " "
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Loads a xib file containing custom button
    // If asssets file does not contain an image with 'imageName' then use it as a label and hide ImageView
    func setUpButton(withText text: String, andImageName imageName: String) {
        Bundle.main.loadNibNamed("CustomButton", owner: self, options: nil)
        customView.frame = self.bounds
        customView.layer.cornerRadius = 14.0
        
        customTextLabel.text = text
        
        if let image = UIImage(named: imageName) {
            customImageView.image = image
        } else {
            customImageView.isHidden = true
            customBigLabel.isHidden = false
            customBigLabel.text = imageName
        }
        customView.isUserInteractionEnabled = false
        addSubview(customView)
    }
}
