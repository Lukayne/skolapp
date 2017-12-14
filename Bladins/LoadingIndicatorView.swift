//
//  LoadingIndicatorView.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-04.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

protocol LoadsIndicator: class {
    var loadingIndicator: LoadingIndicatorView? { get set }
    var overlay: UIView? { get set }
    func startLoading()
    func stopLoading()
}

extension LoadsIndicator where Self: UIViewController {
    func startLoading() {
        view.endEditing(true)
        let size = CGSize(width: 100, height: 100)
        loadingIndicator = LoadingIndicatorView()
        loadingIndicator?.frame = CGRect(x: (view.frame.width - size.width)/2, y: (view.frame.height - size.height)/2, width: size.width, height: size.height)
        loadingIndicator?.isOpaque = false
        overlay = UIView(frame: self.view.frame)
        overlay?.backgroundColor = UIColor.black
        overlay?.alpha = 0.3
        self.view.addSubview(overlay!)
        self.view.addSubview(loadingIndicator!)
    }
    func stopLoading() {
        loadingIndicator?.removeFromSuperview()
        overlay?.removeFromSuperview()
    }
}

class LoadingIndicatorView: UIView {
    
    let color = Color.custom(hexString: "#C3D5D9", alpha: 1).value
    
    override func draw(_ rect: CGRect) {
        
        backgroundColor = .clear
        
        let size = self.frame.size
        let duration: CFTimeInterval = 1
        
        // Scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 1
        
        // Opacity animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        
        opacityAnimation.duration = duration
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circle
        let circle = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        
        path.lineWidth = 2
        
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: 0,
                    endAngle: CGFloat(2 * Double.pi),
                    clockwise: false)
        circle.fillColor = color.cgColor
        circle.backgroundColor = nil
        circle.path = path.cgPath
        circle.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        circle.frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                              y: (layer.bounds.size.height - size.height) / 2,
                              width: 100,
                              height: 100)
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}
