//
//  TodayViewController.swift
//  Crysis Widget
//
//  Created by Richard Smith on 2017-07-31.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import NotificationCenter

class WidgetViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var crisysBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    @IBAction func goToCrisys(_ sender: Any) {
        let myAppUrl = URL(string: "main-screen:")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
                self.crisysBtn.setTitle("Error", for: .normal)
            }
        })
    }
    
}
