//
//  CommunicationViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-30.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

class CommunicationViewController: DefaultViewController, UITableViewDelegate, AlarmDelegate {
    // CommunicationViewController is a child of ContainerViewController and holds the console (with information on Status, Priority and Location) and a container view which embeds the ChatLogViewController.
    
    @IBOutlet var messagesTableView: UITableView!
    
    var rootController: AlarmViewController?
    
    var alarm: Alarm?
    var me: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard alarm != nil else {
            print("Alarm is nil")
            return
        }
        // SETUP DELEGATES
        
        // SETUP DATA-SOURCE
        messagesTableView.delegate = self
        
    }
    

    
    
    func goToHome() {
        rootController?.goToHome()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AlarmDelegate {
            dest.alarm = alarm
            dest.me = me
        }
    }
}
