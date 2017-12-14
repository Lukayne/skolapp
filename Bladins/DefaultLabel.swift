//
//  DefaultLabel.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-11.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class DefaultLabel: UILabel {
    
    var labelColor: UIColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
    
    @IBInspectable var fontColor: Int = 0 {
        didSet {
            switch fontColor {
            case 0: labelColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
            case 1: labelColor = Color.custom(hexString: "181818", alpha: 1).value
            default: labelColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
            }
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        textColor = labelColor
    }
    
}
