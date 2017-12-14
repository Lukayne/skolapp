//
//  MainViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-08-09.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

protocol Unwindable {
    func unwindFrom(alarm: Alarm?)
}

enum MainSections: Int {
    case logo = 0
    case activeAlarms = 1
    case sendAlarm = 2
    case information = 3
    case settings = 4
    
    static let count: Int = {
        var max: Int = 0
        while let _ = MainSections(rawValue: max) { max += 1 }
        return max
    }()
}

class MainViewController: UITableViewController, Unwindable {
    
    var me: User?
    var activeAlarms = [Alarm]()
    var informationEntries = [InformationEntry]()
    var locationManager = CLLocationManager()
    var query: DatabaseQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.view.backgroundColor = Color.custom(hexString: "FAFAFA", alpha: 1).value
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        guard Auth.auth().currentUser != nil && me != nil else {
            goToLogin()
            return
        }
        
        me?.school?.getLocations(completion: { (success, response, error) in
            guard success, error == nil else {
                // SHOW ALERT
                print(error ?? "Locations error")
                return
            }
        })
        
        getInformationEntries { (success, response, error) in
            guard success, let entries = response as? [InformationEntry] else {
                print(error ?? "Error! Failed to get information")
                return
            }
            self.informationEntries = entries
            self.reloadTableView([MainSections.information.rawValue])
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if the user is logged in
        guard Auth.auth().currentUser != nil && me != nil else {
            goToLogin()
            return
        }
        
        // Make sure to request location authorization before using the alarm :)
        locationManager.requestAlwaysAuthorization()
        
        // The database reference is determined by the data of the alarm.
        let ref = Database.database().reference()
        query = ref.child("schools").child(me!.school!.name!).child("alarms/active").queryLimited(toLast: 10)
        query?.observe(.childAdded, with: { [weak self] (snapshot) in
            if let alarmId = snapshot.value as? String {
                self?.getAlarm(id: alarmId, completion: { (success, response, error) in
                    guard success, let alarm = response, self != nil else {
                        print(error ?? "GetAlarm error")
                        return
                    }
                    var isAlreadyAppended = false
                    for activeAlarm in self!.activeAlarms {
                        if activeAlarm.id == alarm.id {
                            isAlreadyAppended = true
                            break
                        }
                    }
                    if !isAlreadyAppended {
                        self?.activeAlarms.append(alarm)
                        self?.reloadTableView([MainSections.activeAlarms.rawValue])
                    }
                })
            } else {
                print("Failed to cast data")
            }
        })
    }
    
    func unwindFrom(alarm: Alarm?) {
        reloadTableView(nil)
        guard alarm != nil, activeAlarms.count > 0 else {
            return
        }
        for i in 0...activeAlarms.count-1 {
            if activeAlarms[i].id == alarm!.id {
                activeAlarms[i] = alarm!
                break
            }
        }
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
    
    func getInformationEntries(completion: @escaping (Bool, Any?, Error?) -> Void) {
        let ref = Database.database().reference()
        ref.child("/schools/\(me!.school!.name!)/information/").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let entries = snapshot.valueInExportFormat() as? [String:NSDictionary] else {
                completion(false, nil, nil)
                return
            }
            var informationEntries = [InformationEntry]()
            for entry in entries {
                let id = entry.key
                let value = entry.value
                if  let title = value["title"] as? String,
                    let summary = value["summary"] as? String {
                    let informationEntry = InformationEntry(id: id, title: title, summary: summary, desc: value["desc"] as? String, imageURL: value["imageUrl"] as? String)
                    informationEntries.append(informationEntry)
                }
            }
            completion(true, informationEntries, nil)
        })
    }
    
    func goToLogin() {
        do {
            try Auth.auth().signOut()
            me = nil
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.switchToLogin()
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        query?.removeAllObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AlarmDelegate {
            print(sender ?? "No alarm sent")
            dest.alarm = sender as? Alarm
            dest.me = me
        }
        if let dest = segue.destination as? InformationViewController {
            dest.entry = sender as? InformationEntry
        }
        if let dest = segue.destination as? GroupsViewController {
            dest.me = me
        }
    }
    
    func reloadTableView(_ sectionIndexes: [Int]?) {
        
        guard let indexes = sectionIndexes else {
            for alarm in activeAlarms {
                alarm.getTimeString()
            }
            self.activeAlarms = self.activeAlarms.sorted { return $0.timestamp! > $1.timestamp! }
            
            let range = NSMakeRange(0, tableView.numberOfSections)
            let sectionsIndex: IndexSet = NSIndexSet(indexesIn: range) as IndexSet
            tableView.reloadSections(sectionsIndex, with: .fade)
            return
        }
        
        if indexes.contains(MainSections.activeAlarms.rawValue) {
            for alarm in activeAlarms {
                alarm.getTimeString()
            }
            self.activeAlarms = self.activeAlarms.sorted { return $0.timestamp! > $1.timestamp! }
        }
        tableView.reloadSections(IndexSet(indexes), with: .fade)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return MainSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case MainSections.logo.rawValue:
            return 1
        case MainSections.activeAlarms.rawValue:
            return 1 + activeAlarms.count
        case MainSections.sendAlarm.rawValue:
            return 1 + (me?.school?.alarmTypes?.count ?? 0)
        case MainSections.information.rawValue:
            return 1 + informationEntries.count
        case MainSections.settings.rawValue:
            return 1 + Setting.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            switch indexPath.section {
            case MainSections.activeAlarms.rawValue:
                if activeAlarms.count > 0 {
                    cell.entry = "OBS! Det finns aktiva alarm!"
                } else {
                    cell.entry = "Det finns inga aktiva alarm"
                }
            case MainSections.sendAlarm.rawValue:
                cell.entry = "Svep höger för att larma"
            case MainSections.information.rawValue:
                cell.entry = "Information"
            case MainSections.settings.rawValue:
                cell.entry = "Inställningar"
            default:
                cell.entry = nil
            }
            return cell
        }
        switch indexPath.section {
        case MainSections.logo.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logo", for: indexPath) as! LogoCell
            cell.setupView()
            return cell
        case MainSections.activeAlarms.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveAlarmCell", for: indexPath) as! ActiveAlarmCell
            cell.alarm = activeAlarms[indexPath.row-1]
            return cell
        case MainSections.sendAlarm.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendAlarmCell", for: indexPath) as! SendAlarmCell
            cell.slidingButton.alarmType = me?.school?.alarmTypes?[indexPath.row - 1]
            cell.slidingButton.delegate = self
//            cell.slidingButton.reset()
            return cell
        case MainSections.information.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as! InformationCell
            cell.entry = informationEntries[indexPath.row - 1]
            if cell.entry?.desc == nil { cell.isUserInteractionEnabled = false }
            return cell
        case MainSections.settings.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            cell.setting = Setting(rawValue: indexPath.row - 1)
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section != 0 {
            return 26
        }
        switch indexPath.section {
        case MainSections.logo.rawValue: return 200
        case MainSections.information.rawValue: return 140
        case MainSections.settings.rawValue: return 60
        default: return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if cell is ActiveAlarmCell || cell is SendAlarmCell || cell is SettingsCell {
//            cell.layer.masksToBounds = false
//            cell.layer.shadowColor = Color.custom(hexString: "303030", alpha: 1).value.cgColor
//            cell.layer.shadowOpacity = 0.6
//            cell.layer.shadowOffset = CGSize(width: 0, height: -5)
//            cell.layer.shadowRadius = 15
//            cell.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height+10)).cgPath
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else {
            return
        }
        switch indexPath.section {
        case MainSections.activeAlarms.rawValue:
            let cell = tableView.cellForRow(at: indexPath) as! ActiveAlarmCell
            performSegue(withIdentifier: "Alarm", sender: cell.alarm)
        case MainSections.information.rawValue:
            let cell = tableView.cellForRow(at: indexPath) as! InformationCell
            performSegue(withIdentifier: "Information", sender: cell.entry)
        case MainSections.settings.rawValue:
            let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
            switch cell.setting! {
            case .profile: break
            case .groups: performSegue(withIdentifier: "Groups", sender: nil)
            case .logout: goToLogin()
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case MainSections.logo.rawValue: return 0
        default: return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if let blockCollectionView = collectionView as? BlockCollectionView {
//            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as? HeaderCollectionReusableView {
//                header.headerLabel.text = blockCollectionView.headerLabelText
//                return header
//            }
//        }
//        return UICollectionReusableView()
//    }
    
}

extension MainViewController: SlideButtonDelegate {
    
    func buttonStatusDidChange(activated: Bool, sender: SlidingButton) {
        print("ButtonStatusChanged!")
        if activated, let alarm = Alarm(alarmType: sender.alarmType!, author: me) {
            activeAlarms.append(alarm)
            performSegue(withIdentifier: "Alarm", sender: alarm)
        }
    }
    
    
//    func uploadTestLocations() {
//        //        FOR TESTING ONLY. Uploads sample data for locations to database.
//        print("WARNING! UPLOADING TEST LOCATIONS!")
//        
//        let sampleLocations: [String:[String:[String:[String]]]] = ["Alfa-hus":["A":["1":["A101", "A102", "A103", "A104", "A105", "A106", "A107", "A108", "A109", "A110", "A111", "A112"], "2":["A201", "A202", "A203"]], "B":["1":["B101", "B102"], "2":["B201", "B202", "B203", "B204"]]], "Beta-hus":["C":["1":["C101", "C102", "C103", "C104"], "2":["C201", "C202", "C203"]], "D":["1":["D101", "D102", "D203"], "2":["D201", "D202", "D203", "D204", "D205"]]]]
//        
//        var id: Int = 0
//        
//        let ref = Database.database().reference()
//        
//        for building in sampleLocations {
//            for section in building.value {
//                for floor in section.value {
//                    for room in floor.value {
//                        let idString = id.description
//                        ref.child("schools").child(me!.school!.name!).child("settings/locations").child(building.key).child(section.key).child(floor.key).child(idString).setValue(room)
//                        id += 1
//                    }
//                }
//            }
//            
//        }
//    }
    
    
}



