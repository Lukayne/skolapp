//
//  SendAlarmCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-16.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class SendAlarmCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundColor = nil
            backgroundImageView.alpha = 0.9
        }
    }
    
    @IBOutlet weak var slidingButton: SlidingButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    func setupView() {
        self.selectionStyle = .none
//        self.slidingButton.reset()
    }
    
}
