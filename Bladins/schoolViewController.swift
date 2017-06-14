//
//  ViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-12.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let me = User(email: "abc@.com", school: "Skola", name: "Adam")
        let alert = Alert(type: .accident, user: me)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

