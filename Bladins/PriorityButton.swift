//
//  PriorityButton.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

public enum Priority: Int {
    case low = 0
    case medium = 1
    case high = 2
    case veryHigh = 3
    
    var label: String {
        switch self {
        case .low: return "Låg"
        case .medium: return "Medel"
        case .high: return "Hög"
        case .veryHigh: return "Mycket hög"
        }
    }
}

// Designable
class PriorityButton: UIButton {
    
    var priority: Priority? {
        didSet {
            switch priority! {
            case .low: backgroundColor = Color.custom(hexString: "FDFFB3", alpha: 0.3).value
            case .medium: backgroundColor = Color.custom(hexString: "FFD663", alpha: 0.3).value
            case .high: backgroundColor = Color.custom(hexString: "FF8159", alpha: 0.3).value
            case .veryHigh: backgroundColor = Color.custom(hexString: "FF2020", alpha: 0.3).value
            }
            setTitle(priority?.label, for: .normal)
        }
    }
    
    @IBInspectable var priorityValue: Int = 0 {
        didSet {
            priority = Priority(rawValue: priorityValue)
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
        setTitleColor(Color.custom(hexString: "9B9B9B", alpha: 1).value, for: .normal)
        layer.cornerRadius = 15
    }
    
}
