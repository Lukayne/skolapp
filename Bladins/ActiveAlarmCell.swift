//
//  NewAlarmCollectionViewCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-09.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class ActiveAlarmCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundColor = nil
            backgroundImageView.alpha = 0.9

        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {    }
    
    var timer: Timer?
    
    var alarm: Alarm? {
        didSet {
//            setupView()
            timer = nil
            titleLabel.text = alarm?.alarmType?.name ?? "Larm utlöst"
            locationLabel.text = alarm?.location?.locationDescription()
            updateTime()
        }
    }
    
    @objc func updateTime() {
        guard alarm?.timestamp != nil else {
            return
        }
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
        let interval = TimeInterval(alarm!.timestamp!)
        let secondsAgo = Int(round(Date.timeIntervalSinceReferenceDate - interval))
        if secondsAgo >= 60 {
            if secondsAgo >= 3600 {
                timeLabel.text = "klockan \(alarm?.timeString ?? "??")"
            } else if secondsAgo >= 120 {
                let minutesAgo = secondsAgo/60
                timeLabel.text = "för \(String(minutesAgo)) minuter sedan"
            } else {
                timeLabel.text = "för 1 minut sedan"
            }
        } else {
            timeLabel.text = "för \(String(secondsAgo)) sekunder sedan"
        }
    }
    
}
