//
//  MessageView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-22.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    var color: UIColor?
    
    var messageType: MessageType? {
        didSet {
            switch messageType! {
            case .log:
                // red
                backgroundColor = Color.custom(hexString: "934448", alpha: 1).value
                break
            case .mine:
                // blue
                backgroundColor = Color.custom(hexString: "3E5C80", alpha: 1).value
                break
            case .author:
                // red
                backgroundColor = Color.custom(hexString: "934448", alpha: 1).value
                break
            case .others:
                // gray
                backgroundColor = Color.custom(hexString: "C0C0C0", alpha: 1).value
                break
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
        
//        backgroundColor = color
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = Color.custom(hexString: "A7A7A7", alpha: 1).value.cgColor
        layer.borderWidth = 1
        
    }

}
