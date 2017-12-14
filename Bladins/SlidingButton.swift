//
//  SlidingButton.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-17.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

protocol SlideButtonDelegate {
    func buttonStatusDidChange(activated: Bool, sender: SlidingButton)
}

// Designable
class SlidingButton: UIView {
    
    var delegate: SlideButtonDelegate?
    var alarmType: AlarmType? {
        didSet {
            alarmLabelText = alarmType?.name
        }
    }
    var alarmLabelText: String? {
        didSet {
            buttonLabel.text = alarmLabelText
        }
    }
    
    var unlockView: UIView?
    var dragPoint = UIView()
    var dragPointWidth: CGFloat = 40
    var buttonLabel = UILabel()
    var dragPointButtonLabel = UILabel()
    var backgroundImageView = UIImageView()
    var unlocked = false
    var layoutSet = false
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !layoutSet{
            self.setupView()
            self.layoutSet = true
        }
    }
    
    func setupView(){
        
        dragPointWidth = self.frame.width * 0.1
        
        buttonLabel = DefaultLabel(frame: CGRect(x: dragPointWidth + 64, y: 0, width: self.frame.size.width - dragPointWidth - 64, height: self.frame.size.height))
        buttonLabel.text = alarmLabelText
        buttonLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(self.buttonLabel)
        
        dragPoint = UIView(frame: CGRect(x: self.dragPointWidth - self.frame.size.width, y: 0, width: self.frame.size.width + dragPointWidth, height: self.frame.size.height))
        dragPoint.translatesAutoresizingMaskIntoConstraints = false
        dragPoint.backgroundColor = .clear
        dragPoint.layer.masksToBounds = true
        self.addSubview(self.dragPoint)
        
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width + dragPointWidth, height: self.frame.size.height))
        backgroundImageView.image = #imageLiteral(resourceName: "sliding_bar")
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.alpha = 0.9
        dragPoint.addSubview(self.backgroundImageView)
        
        dragPointButtonLabel = DefaultLabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width + dragPointWidth, height: self.frame.size.height))
        dragPointButtonLabel.textAlignment = .center
        dragPointButtonLabel.text = "LARMET AKTIVERAS"
        dragPointButtonLabel.font = UIFont.systemFont(ofSize: 16)
        dragPoint.addSubview(self.dragPointButtonLabel)
        
        dragPoint.isOpaque = false
        dragPoint.alpha = 0.7
        self.bringSubview(toFront: self.dragPoint)
        
        self.layer.masksToBounds = true
        
        // start detecting pan gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(sender:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        self.dragPoint.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panDetected(sender: UIPanGestureRecognizer) {
        var translatedPoint = sender.translation(in: self)
        translatedPoint = CGPoint(x: translatedPoint.x, y: self.frame.size.height / 2)
        sender.view?.frame.origin.x = (dragPointWidth - self.frame.size.width) + translatedPoint.x
        
        let progress: Double = Double(1 + (sender.view!.frame.origin.x) / (self.dragPoint.frame.size.width))
        buttonLabel.alpha = (1 - CGFloat(progress))
        
        if sender.state == .ended {
            let velocityX = sender.velocity(in: self).x * 0.2
            var finalX = translatedPoint.x + velocityX
            if finalX < 0 {
                finalX = 0
            } else if finalX + self.dragPointWidth > (self.frame.size.width - dragPointWidth) {
                unlocked = true
                self.unlock()
            }
            
            let animationDuration: Double = abs(Double(velocityX) * 0.0002) + 0.2
            UIView.transition(with: self, duration: animationDuration, options: UIViewAnimationOptions.curveEaseOut, animations: {
            }, completion: { (success) in
                if success {
                    self.animationFinished()
                }
            })
        }
    }
    
    func animationFinished(){
        if !unlocked{
            self.reset()
        }
    }
    
    //lock button animation (SUCCESS)
    func unlock() {
//        if let window = UIApplication.shared.keyWindow {
//            unlockView = UIView()
//            unlockView?.backgroundColor = .red
//            unlockView?.alpha = 0.6
//            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                window.insertSubview(self.unlockView!, belowSubview: self)
//                self.unlockView?.frame = window.frame
//            })
//            
//        }
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame = CGRect(x: -self.dragPointWidth, y: 0, width: self.dragPoint.frame.size.width, height: self.dragPoint.frame.size.height)
            self.dragPointButtonLabel.text = "Larmat!"
        }) { (success) in
            if success {
                // ber mainviewcontroller att köra en funktion
                self.delegate?.buttonStatusDidChange(activated: true, sender: self)
                _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reset), userInfo: nil, repeats: false)
            }
        }
    }
    
    //reset button animation (RESET)
    @objc func reset() {
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.dragPoint.frame = CGRect(x: self.dragPointWidth - self.frame.size.width, y: 0, width: self.dragPoint.frame.size.width, height: self.dragPoint.frame.size.height)
            self.buttonLabel.alpha = 1
        }) { (success) in
            if success {
//                self.dragPoint.backgroundColor = Color.custom(hexString: "595262", alpha: 1).value
                self.unlocked = false
                //self.delegate?.buttonStatus("Locked")
            }
        }
    }
}
