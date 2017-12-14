//
//  KeyboardAvoidable.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit


// https://blog.propellerlabs.co/making-life-easier-with-a-keyboardavoidable-protocol-62c6689f603d

// typealias HandlesKeyboard = KeyboardAvoidable & UITextFieldDelegate

protocol KeyboardAvoidable {
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] { get }
    func addKeyboardObservers()
    func removeKeyboardObservers()
}

extension KeyboardAvoidable where Self: UIViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default
            .addObserver(forName: NSNotification.Name.UIKeyboardWillShow,
                         object: nil,
                         queue: nil) { [weak self] notification in
                            self?.keyboardWillShow(notification)
        }
        
        NotificationCenter.default
            .addObserver(forName: NSNotification.Name.UIKeyboardWillHide,
                         object: nil,
                         queue: nil) { [weak self] notification in
                            self?.keyboardWillHide(notification)
        }
        
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default
            .removeObserver(self,
                            name: NSNotification.Name.UIKeyboardWillShow,
                            object: nil)
        
        NotificationCenter.default
            .removeObserver(self,
                            name: NSNotification.Name.UIKeyboardWillHide,
                            object: nil)
    }
    
    typealias KeyboardHeightDuration = (height: CGFloat, duration: Double)
    
    private func getKeyboardInfo(notification: Notification) -> KeyboardHeightDuration? {
        guard let userInfo = notification.userInfo else { return nil }
        guard let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return nil }
        guard let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return nil }
        return (rect.height, duration)
    }
    
    private func keyboardWillShow(_ notification: Notification) {
        guard let info = getKeyboardInfo(notification: notification) else { return }
        animateConstraints(info.height, duration: info.duration)
    }
    
    private func keyboardWillHide(_ notification: Notification) {
        guard let info = getKeyboardInfo(notification: notification) else { return }
        animateConstraints(0, duration: info.duration)
    }
    
    private func animateConstraints(_ constant: CGFloat, duration: Double) {
        layoutConstraintsForKeyboard.forEach { c in
            c.constant = constant
        }
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
}

//protocol CloseKeyboardOnTouch {
//    func closeKeyboard()
//}
//
//extension CloseKeyboardOnTouch where Self: UIViewController {
//    
//    
//    
//}







