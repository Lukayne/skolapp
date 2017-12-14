//
//  AlarmButton.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class AlarmButton: UIButton {
    
    var alarmType: alarmTypes = .other {
        didSet {
            setupView()
            
            switch alarmType {
            case .threat:
                backgroundColor = Color.red.value
                setTitle("HOT", for: .normal)
                titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
            case .accident:
                backgroundColor = Color.orange.value
                setTitle("OLYCKA", for: .normal)
            case .intruder:
                backgroundColor = Color.yellow.value
                setTitle("BROTT", for: .normal)
            case .other:
                backgroundColor = Color.light.value
                setTitle("...", for: .normal)
            }
        }
    }
    
    @IBInspectable var buttonTypeName: String? {
        willSet {
            // Ensure user enters a valid shape while making it lowercase.
            // Ignore input if not valid.
            if let newButton = alarmTypes(rawValue: newValue?.lowercased() ?? "") {
                alarmType = newButton
            }
        }
    }
    
    func setupView() {
        // MAKE BUTTON ROUND
        layer.cornerRadius = max(bounds.width, bounds.height) / 2
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.8
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        setTitleColor(Color.redFont.value, for: .normal)
        
    }
    
    // CANCEL TOUCHES OUTSIDE OF BUTTON
    var touchPath: UIBezierPath {
        return UIBezierPath(ovalIn: self.bounds)
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touchPath.contains(point)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
}
