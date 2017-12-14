////
////  ContainerViewController.swift
////  Bladins
////
////  Created by Adam Alfredsson on 2017-07-29.
////  Copyright © 2017 Richard Smith. All rights reserved.
////
//
//import UIKit
//import FirebaseDatabase
//
//class ContainerViewController: UIViewController, AlarmDelegate {
//    // ContainerViewController manages the viewcontroller sequence when creating the alarm. All viewcontrollers refer to this when the container need to switch viewcontroller.
//    
//    var alarm: Alarm?
//    var me: User?
//    
//    var currentChild: UIViewController?
//    var segueIdentifier: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // If the alarm is instantiated by the current user, then immidiately navigate to PriorityViewController. Otherwise, skip directly to CommunicationViewController
//        if alarm?.author?.id == me?.id {
//            navigate(segue: "SetPriority")
//        } else {
//            navigate(segue: "Communication")
//        }
//        
//    }
//    
//    func navigate(segue: String) {
//        segueIdentifier = segue
//        performSegue(withIdentifier: segue, sender: nil)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if let dest = segue.destination as? AlarmDelegate {
//            dest.alarm = alarm
//            dest.me = me
//        }
//        
//        if segue.identifier == segueIdentifier {
//            
//            // Avoids creation of a stack of view controllers
//            currentChild?.view.removeFromSuperview()
//            
//            // Adds View Controller
//            let dest = segue.destination
//            self.addChildViewController(dest)
//            
//            dest.view.frame = self.view.frame
//            dest.view.layoutIfNeeded()
//            self.view.addSubview(dest.view)
//            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
//                dest.didMove(toParentViewController: self)
//            }, completion: { completed in
//                // maybe do something here
//            })
//            currentChild = dest
//            
//        }
//        
//    }
//    
//}
