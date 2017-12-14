//
//  DefaultButton.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class DefaultButton: UIButton {
    
//    var buttonBackgroundColor: UIColor =
    var fontColor: UIColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
    
    @IBInspectable var backgroundType: Int = 0 {
        didSet {
            switch backgroundType {
            case 1:
                setBackgroundImage(#imageLiteral(resourceName: "blue_bar"), for: .normal)
            case 2:
                setBackgroundImage(#imageLiteral(resourceName: "green_bar"), for: .normal)
            case 3:
                setBackgroundImage(#imageLiteral(resourceName: "green_bar"), for: .normal)
                backgroundColor = .black
                setImage(#imageLiteral(resourceName: "arrow_back").withRenderingMode(.alwaysOriginal), for: .normal)
                imageView?.contentMode = .scaleAspectFit
                imageView?.alpha = 0.6
                let inset = self.frame.width * 0.3
                imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
            case 4:
                setBackgroundImage(#imageLiteral(resourceName: "red_bar"), for: .normal)
            default: break
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        
        setTitleColor(fontColor, for: .normal)
        
    }
    
}
