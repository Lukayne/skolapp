//
//  homeViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-14.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import FirebaseMessaging

class HomeViewController: DefaultViewController, UICollectionViewDelegate {
    
    @IBOutlet var alarmsCollectionView: DefaultCollectionView!
    @IBOutlet var logo: UIView!
    
    var me: User?
    var activeAlarms = [Alarm]() {
        didSet {
            alarmsCollectionView.reloadData()
        }
    }
    
    var locations: [String:[String:[String:[String:String]]]]?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Messaging.messaging().subscribe(toTopic: "/topics/\((me?.school?.name)!)/")
        
        
        
        guard Auth.auth().currentUser != nil && me != nil else {
            goToLogin()
            return
        }
        
        me?.school?.getLocations(completion: { (success, response, error) in
            guard success, error == nil else {
                // SHOW ALERT
                print(error ?? "No success")
                return
            }
        })
        
        alarmsCollectionView.delegate = self
        alarmsCollectionView.dataSource = self
        
        getActiveAlarms { (success, response, error) in
            guard success, error == nil else {
                print(error ?? "No success")
                return
            }
            DispatchQueue.main.async {
                self.alarmsCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if the user is logged in
        guard Auth.auth().currentUser != nil && me != nil else {
            goToLogin()
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Make sure to request location authorization before using the alarm :)
        locationManager.requestAlwaysAuthorization()
    }
    
    func getActiveAlarms(completion: @escaping (Bool, Any?, Error?) -> Void) {
        // Check for current active alarms
        let ref = Database.database().reference()
        ref.child("schools").child(me!.school!.name!).child("alarms/active").observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? NSDictionary {
                guard let alarmIds = data.allValues as? [String] else {
                    return
                }
                var i = 0
                for alarmId in alarmIds {
                    self.getAlarm(id: alarmId, completion: { (success, response, error) in
                        if let error = error {
                            print(error)
                        }
                        
                        if let alarm = response {
                            self.activeAlarms.append(alarm)
                        }
                        
                        i += 1
                        if i >= alarmIds.count {
                            completion(true, nil, nil)
                        }
                        
                    })
                }
            } else {
                completion(false, nil, nil)
            }
        }, withCancel: { (error) in
            completion(false, nil, error)
        })
    }
    
    func getAlarm(id: String, completion: @escaping (Bool, Alarm?, Error?) -> Void) {
        _ = Alarm(id: id, school: self.me!.school!, completion: {(success, response, error) in
            guard success, let alarm = response as? Alarm else {
                completion(false, nil, error)
                return
            }
            completion(true, alarm, nil)
        })
    }
    
    @IBAction func alarmButtonPress(_ sender: AlarmButton) {
        var alarm: Alarm?
        switch sender.alarmType {
        case .threat:
            print("Threat")
            alarm = Alarm(type: .threat, author: me)
            break
        case .accident:
            print("Accident")
            alarm = Alarm(type: .accident, author: me)
            break
        case .intruder:
            print("Intruder")
            alarm = Alarm(type: .intruder, author: me)
            break
        case .other:
            print("Other")
            return
        }
        performSegue(withIdentifier: "Alarm", sender: alarm)
    }
    
    func goToLogin() {
        me = nil
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchToLogin()
    }
    
    @IBAction func logOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                goToLogin()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            goToLogin()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AlarmDelegate {
            dest.alarm = sender as? Alarm
            print(sender ?? "No alarm sent")
            dest.me = me
        }

    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeAlarms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AlarmCollectionViewCell
        cell.alarm = activeAlarms[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AlarmCollectionViewCell
        for visibleCell in collectionView.visibleCells as! [AlarmCollectionViewCell] {
            visibleCell.deselected()
        }
        cell.selected()
        performSegue(withIdentifier: "Communication", sender: cell.alarm)
    }
    
}

    /*
     func uploadTestLocations() {
        // FOR TESTING ONLY. Uploads sample data for locations to database.
        
        let sampleLocations: [String:[String:[String:[String]]]] = ["Alfa-hus":["A":["1":["A101", "A102"], "2":["A201", "A202"]], "B":["1":["B101", "B102"], "2":["B201", "B202"]]], "Beta-hus":["C":["1":["C101", "C102"], "2":["C201", "C202"]], "D":["1":["D101", "D102"], "2":["D201", "D202"]]]]
        
        var id: Int = 0
        
        ref = Database.database().reference()
        
        for building in sampleLocations {
            for section in building.value {
                for floor in section.value {
                    for room in floor.value {
                        let idString = id.description
                        print(idString)
                        print(me?.school)
                        ref?.child("schools").child("Vittra").child("locations").child(building.key).child(section.key).child(floor.key).child(idString).setValue(room)
                        id += 1
                    }
                }
            }

        }
    }
    */

