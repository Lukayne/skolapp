//
//  PriorityViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-26.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class SetupViewController: DefaultViewController, AlarmDelegate, UITableViewDelegate {
    // This is the viewcontroller where the creator of an alarm sets the priority
    
    
    @IBOutlet var setupTableView: DefaultTableView!
    
    var alarm: Alarm?
    var me: User?
    var rootController: AlarmViewController?
    
    let communicationDataSource = CommunicationDataSource()
    let priorityDataSource = PriorityDataSource()
    let locationDataSource = LocationDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Setup viewDidLoad")
    
    }
    

    
    
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AlarmDelegate {
            dest.me = me
            dest.alarm = alarm
        }
    }
    
}
