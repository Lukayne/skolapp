//
//  ViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-12.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseDatabase


class SchoolViewController: DefaultViewController, LoadsIndicator {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var overlay: UIView?
    var loadingIndicator: LoadingIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SETUP DELEGATES 
        schoolTextField.delegate = self
        pinTextField.delegate = self
        
        schoolTextField.text = "Testing"
        pinTextField.text = "9999"
        
        addKeyboardObservers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        removeKeyboardObservers()
        stopLoading()
    }
    
    @IBAction func go(_ sender: UIButton) {
        startLoading()
        errorLabel.text = ""
        authorize { (success, response, error) in
            guard success, error == nil, let school = response as? String else {
                print(error ?? "Error!")
                self.stopLoading()
                if let errorLabelText = response as? String {
                    self.errorLabel.text = errorLabelText
                }
                return
            }
            self.performSegue(withIdentifier: "CreateUser", sender: school)
        }
    }
    
    func authorize(completion: @escaping (Bool, Any?, Error?) -> Void) {
        if schoolTextField.text != "" && pinTextField.text != "" {
            let ref = Database.database().reference()
            ref.child("schools/\(schoolTextField.text!)/settings/pin").observeSingleEvent(of: .value, with: { (snapshot) in
                if let pin = snapshot.value as? NSNumber {
                    if self.pinTextField.text! == pin.stringValue {
                        completion(true, self.schoolTextField.text, nil)
                    } else {
                        completion(false, "Fel pin-kod", nil)
                    }
                } else {
                    completion(false, "Ingen skola hittades", nil)
                }
            }, withCancel: { (error) in
                print(error.localizedDescription)
                completion(false, nil, error)
            })
        } else {
            completion(false, "Fyll i samtliga fält", nil)
        }
    }
    
    @IBAction func goBack(_ sender: DefaultButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateUser" {
            let dest = segue.destination as! CreateUserViewController
            
            dest.school = sender as? String
        }
    }
}


extension SchoolViewController: KeyboardAvoidable {
    
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] {
        return [bottomConstraint]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SchoolViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField != pinTextField {
            pinTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}

