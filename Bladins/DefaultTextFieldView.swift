//
//  DefaultTextField.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class DefaultTextFieldView: UIView {
    
    var cornerRadius: CGFloat? {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = cornerRadius!
        }
    }
    var placeholderColor: UIColor = Color.custom(hexString: "9B9B9B", alpha: 1).value
    var inputColor: UIColor = Color.custom(hexString: "000000", alpha: 1).value
    
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
        backgroundColor = Color.custom(hexString: "#FFFFFF", alpha: 1).value
        layer.borderWidth = 1
        layer.borderColor = Color.custom(hexString: "#CCCCCC", alpha: 1).value.cgColor
        layer.cornerRadius = 15
        
        for subview in subviews {
            if let textField = subview as? UITextField {
                textField.borderStyle = .none
                textField.textColor = inputColor
                textField.font = UIFont.systemFont(ofSize: 16)
                textField.attributedPlaceholder = NSAttributedString(string: "\(textField.placeholder ?? "")", attributes: [NSAttributedStringKey.foregroundColor: placeholderColor])
            }
            if let textView = subview as? UITextView {
                textView.textColor = inputColor
                textView.font = UIFont.systemFont(ofSize: 16)
            }
        }
        
    }
}
