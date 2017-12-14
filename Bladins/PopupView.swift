//
//  PopupView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-06.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class PopupView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.8
    }
    
}
