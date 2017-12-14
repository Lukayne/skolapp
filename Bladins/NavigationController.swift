//
//  NavigationController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-23.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, AlarmDelegate {
    
    var didLaunchFromRemoteNotification: Bool?
    
    var alarm: Alarm?
    var me: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let child = childViewControllers.first as? MainViewController {
            child.me = me
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
    }

}
