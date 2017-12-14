//
//  SetupAlarmCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class DefaultCollectionViewCell: UICollectionViewCell {
    
    var color = UIColor.white
    
    func setupView() {
        clipsToBounds = false
        backgroundColor = color
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.6
    }
    
    func selected() {
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundColor = UIColor.lightText
        })
        bounce()
    }
    
    func deselected() {
        backgroundColor = color
    }
    
    func bounce() {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .allowUserInteraction, animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
}

class SetupAlarmCell: DefaultCollectionViewCell {
    // The standard UICollectionViewCell during the setup process of the alarm. Mostly manages the visual, like what happens when it is selected.
    
    @IBOutlet weak var label: UILabel!
    
    var value: String? {
        didSet {
            setupView()
            label.text = value!
            label.font = UIFont(name: "Copperplate-Bold", size: 16)
        }
    }
    
}
