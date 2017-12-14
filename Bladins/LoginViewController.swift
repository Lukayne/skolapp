//
//  LoginViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-14.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: DefaultViewController, LoadsIndicator {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var finalTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    var overlay: UIView?
    var loadingIndicator: LoadingIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        addKeyboardObservers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        removeKeyboardObservers()
        stopLoading()
    }
        
    
    @IBAction func login(_ sender: Any) {
        startLoading()
        errorLabel.text = ""
        loginAttempt { (success, response, error) in
            guard success, error == nil else {
                self.stopLoading()
                // SHOW ALERT
                if let errorLabelText = response as? String {
                    self.errorLabel.text = errorLabelText
                }
                return
            }
        }
    }
    
    func loginAttempt(completion: @escaping (Bool, Any?, Error?) -> Void) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            if Auth.auth().currentUser == nil {
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                    guard error == nil, let uid = user?.uid else {
                        completion(false, "Inloggning misslyckades", error)
                        return
                    }
                    
                    // GO TO HOMEVIEWCONTROLLER
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.switchToMain(userId: uid, completion: { (success, response, error) in
                        guard success, error != nil else {
                            completion(false, nil, error)
                            return
                        }
                        completion(true, nil, nil)
                    })
                })
            } else {
                do {
                    try Auth.auth().signOut()
                } catch { }
                completion(false, "Försök igen", nil)
            }
        } else {
            completion(false, "Fyll i samtliga fält", nil)
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LoginViewController: KeyboardAvoidable {
    
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] {
        return [bottomConstraint]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField != passwordTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
