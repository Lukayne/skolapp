//
//  BackgroundArcView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

// Designable
class BackgroundArcView: UIView {

    var bottomColor = Color.custom(hexString: "#C3D5D9", alpha: 1).value
    var topColor = Color.custom(hexString: "#B4C9CD", alpha: 1).value
    
    override func draw(_ rect: CGRect) {
        
        // SET ARC
        let startAngle = CGFloat(Double.pi)
        let endAngle = CGFloat(0)
        
        let center = CGPoint(x:bounds.width/2, y: bounds.height)
        let arcWidth: CGFloat = bounds.height/2 + 60
        
        let path = UIBezierPath(arcCenter: center,
                                radius: bounds.height - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = arcWidth
        topColor.setStroke()
        bottomColor.setFill()
        path.stroke()
        path.fill()
        
        // SET LAYER PATH
        let mask = CAShapeLayer()
        let maskPath = UIBezierPath(arcCenter: center,
                                    radius: bounds.height,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
        mask.path = maskPath.cgPath
        layer.mask = mask
        
        // SET SHADOW
        layer.shadowPath = maskPath.cgPath
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: -10)
        layer.shadowOpacity = 0.8
        
    }
    
}
