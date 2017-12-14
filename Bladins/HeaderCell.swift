//
//  HeaderCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-10.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    
    @IBOutlet var headerTextLabel: UILabel!
    
    var entry: Any? {
        didSet {
            setupView()
            if let string = entry as? String {
                headerTextLabel.text = string
            }
        }
    }
    
    func setupView() {
        backgroundColor = Color.custom(hexString: "717C89", alpha: 0.8).value
        self.isOpaque = false
        self.isUserInteractionEnabled = false
    }
    
}
