//
//  SetupCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class SetupCell: UITableViewCell {
    
    @IBOutlet var titleLabel: DefaultLabel!
    @IBOutlet var descLabel: DefaultLabel!
    
    var value: Any? {
        didSet {
            switch self.reuseIdentifier! {
            case "PriorityCell":
                if let priority = value as? Priority {
                    titleLabel.text = priority.name
                }
            case "LocationCell":
                descLabel.text = ""
                if let building = value as? Building {
                    titleLabel.text = building.name
                }
                if let section = value as? Section {
                    titleLabel.text = section.name
                }
                if let floor = value as? Floor {
                    titleLabel.text = floor.name
                }
                if let room = value as? Room {
                    titleLabel.text = room.name
                    descLabel.text = room.desc
                }
            default: break
            }
        }
    }
    
}
