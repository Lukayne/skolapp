//
//  ConsoleTableViewCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-30.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var keyText: String? {
        didSet {
            if keyText == "Visa plats" {
                keyLabel.textColor = Color.custom(hexString: "4A90E2", alpha: 1).value
                keyLabel.font = UIFont.boldSystemFont(ofSize: keyLabel.font.pointSize)
            } else {
                keyLabel.textColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
                keyLabel.font = UIFont.systemFont(ofSize: keyLabel.font.pointSize)
            }
            keyLabel.text = keyText
        }
    }
    
    var valueText: String? {
        didSet {
            valueLabel.text = valueText
        }
    }
    
    func setCellFocused(_ focused: Bool) {
        if focused {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView.alpha = 0.5
            })
        }
    }
    
}
