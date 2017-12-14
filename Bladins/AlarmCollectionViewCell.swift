//
//  AlarmTableViewCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-04.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class AlarmCollectionViewCell: DefaultCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var alarm: Alarm? {
        didSet {
            setupView()
            
            guard let alarmType = alarm!.alarmType else {
                return
            }
            
            switch alarmType {
            case .threat : titleLabel.text = "Hot utlöst"
            case .accident: titleLabel.text = "Olycka"
            case .intruder: titleLabel.text = "Brott"
            default: titleLabel.text = "Larm utlöst"
            }
            
            if let room = alarm!.room {
                locationLabel.text = room
            }
            if let timeString = alarm!.timeString {
                timeLabel.text = timeString
            }
        }
    }

}
