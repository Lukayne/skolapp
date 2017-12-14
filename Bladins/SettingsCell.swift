//
//  SettingsCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

public enum Setting: Int {
    case profile = 0
    case groups = 1
    case logout = 2
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Setting(rawValue: max) { max += 1 }
        return max
    }()
}

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundColor = nil
            backgroundImageView.alpha = 0.9
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var setting: Setting? {
        didSet {
            guard setting != nil else {
                return
            }
            switch setting! {
            case .profile: titleLabel.text = "Min profil"
            case .groups: titleLabel.text = "Mina grupper"
            case .logout: titleLabel.text = "Logga ut"
            }
        }
    }
    
}
