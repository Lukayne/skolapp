//
//  createUserViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-14.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseMessaging



class CreateUserViewController: DefaultViewController, LoadsIndicator {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var school: String?
    var overlay: UIView?
    var loadingIndicator: LoadingIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SETUP DELEGATES
        nameTextField.delegate = self
        emailTextField.delegate = self
        password1TextField.delegate = self
        password2TextField.delegate = self
        
        schoolLabel.text = school
        
        nameTextField.text = "Richard Smith"
        emailTextField.text = "richard@crisys.se"
        password1TextField.text = "password123"
        password2TextField.text = "password123"
        
        addKeyboardObservers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        removeKeyboardObservers()
        stopLoading()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        schoolLabel.text = school
//    }

    @IBAction func go(_ sender: UIButton) {
        startLoading()
        errorLabel.text = ""
        createUser { (success, response, error) in
            self.stopLoading()
            guard success, error == nil, let user = response as? User else {
                if let errorLabelText = response as? String {
                    self.errorLabel.text = errorLabelText
                }
                return
            }
            self.performSegue(withIdentifier: "Groups", sender: user)
        }
    }
    
    func createUser(completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        guard password1TextField.text == password2TextField.text else {
            completion(false, "Lösenorden matchar inte", nil)
            return
        }
        
        guard (password1TextField.text?.characters.count)! >= 6 else {
            completion(false, "Lösenordet är för kort", nil)
            return
        }
        
        guard nameTextField.text != "" && emailTextField.text != "" && password1TextField.text != "" && password2TextField.text != "" else {
            completion(false, "Fyll i samtliga fält", nil)
            return
        }
        
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.password1TextField.text!, completion: { (user, error) in
            guard error == nil else {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    self.errorLabel.text = errorCode.errorMessage
                }
                completion(false, nil, nil)
                return
            }
            
            guard let id = user?.uid else {
                print("Couldn't get userID")
                completion(false, nil, nil)
                return
            }
            
            _ = User(id: id, school: self.school!, name: self.nameTextField.text!, completion: { (success, response, error) in
                
                guard success, error == nil else {
                    // SHOW ALERT
                    completion(false, "Användaren kunde inte skapas", error)
                    return
                }
                
                if let user = response as? User {
                    completion(true, user, nil)
                } else {
                    completion(false, nil, nil)
                }
                
            })
            
        })
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? GroupsViewController,
            let user = sender as? User {
            dest.me = user
        }
    }
    
}

extension CreateUserViewController: KeyboardAvoidable {
    
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] {
        return [bottomConstraint]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension CreateUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}


