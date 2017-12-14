//
//  AlarmViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-26.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

protocol AlarmDelegate: class {
    // AlarmDelegate is used to push variables 'alarm' and 'me' through the sequence of viewcontrollers for creating the alarm.
    var alarm: Alarm? { get set }
    var me: User? { get set }
}

protocol AlarmViewControllerDelegate: class {
    var alarmTableView: UITableView! { get }
    var alarm: Alarm? { get set }
    var me: User? { get }
    func switchDataSource(_ dataSourceType: AlarmDataSource)
    func reloadTableView(_ tableView: UITableView?)
}

protocol AlarmTableViewDataSource: UITableViewDataSource {
    var delegate: AlarmViewControllerDelegate? { get set }
}

public enum AlarmDataSource: Int {
    case priority = 0
    case location = 1
    case communication = 2
}

protocol ConsoleDelegate: class {
    var userIsAdmin: Bool { get }
    var userIsAuthor: Bool { get }
    var alarm: Alarm? { get }
    var consoleTableView: UITableView! { get }
    var alarmTableView: UITableView! { get }
    func reloadTableView(_ tableView: UITableView?)
}

//public enum Priority: Int {
//    case low = 0
//    case medium = 1
//    case high = 2
//    case veryHigh = 3
//    
//    var label: String {
//        switch self {
//        case .low: return "Låg"
//        case .medium: return "Medel"
//        case .high: return "Hög"
//        case .veryHigh: return "Mycket hög"
//        }
//    }
//}

class AlarmViewController: DefaultViewController, AlarmDelegate, AlarmViewControllerDelegate, ConsoleDelegate, UITableViewDelegate {
    
    @IBOutlet var consoleTableView: UITableView!
    @IBOutlet var alarmTableView: UITableView!
    @IBOutlet var consoleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var deactivateButton: DefaultButton!
    @IBOutlet var continueButton: DefaultButton!
    @IBOutlet var messageInputView: DefaultTextFieldView!
    
    @IBOutlet var messageTextView: UITextView! {
        didSet {
            messageTextView.textContainerInset = UIEdgeInsetsMake(15, 0, 15, 0)
        }
    }
    @IBOutlet var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var messageTextViewPlaceholder: DefaultLabel!
    
    var didLaunchFromRemoteNotification: Bool?
    
    var locationManager = CLLocationManager()
    
    var alarm: Alarm? {
        didSet {
            if alarm?.authorId == me?.id {
                userIsAuthor = true
            }
        }
    }
    var me: User? {
        didSet {
            if alarm?.authorId == me?.id {
                userIsAuthor = true
            }
            if me?.isAdmin == true {
                userIsAdmin = true
            } else {
                userIsAdmin = false
            }
        }
    }
    var userIsAdmin = false
    var userIsAuthor = false
    var isInInitialSetup = true
    
    let consoleDataSource = ConsoleDataSource()
    let priorityDataSource = PriorityDataSource()
    let locationDataSource = LocationDataSource()
    let communicationDataSource = CommunicationDataSource()
    
    var query: DatabaseQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard alarm != nil, me != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        print("AlarmViewController viewDidLoad")
        
        alarmTableView.transform = CGAffineTransform (scaleX: 1,y: -1)
        navigationController?.delegate = self
        
        priorityDataSource.delegate = self
        locationDataSource.delegate = self
        communicationDataSource.delegate = self
        consoleDataSource.delegate = self
        messageTextView.delegate = self
        alarmTableView.delegate = self
        consoleTableView.delegate = self
        consoleTableView.dataSource = consoleDataSource
        
        if me?.id == alarm?.authorId && alarm?.priority == nil {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            switchDataSource(.priority)
        } else {
            switchDataSource(.communication)
        }
        
        adjustTextViewHeight(messageTextView, messageTextViewHeightConstraint)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObservers()
        startObserving()
    }
    
    func startObserving() {
        let ref = Database.database().reference()
        query = ref.child("schools/\(me!.school!.name!)/alarms/\(alarm!.id!)")
        query?.observe(.childAdded, with: { (snapshot) in
            self.updateConsole(snapshot: snapshot)
        })
        query?.observe(.childChanged, with: { (snapshot) in
            self.updateConsole(snapshot: snapshot)
        })
    }
    
    func stopObserving() {
        query?.removeAllObservers()
    }
    
    func switchDataSource(_ dataSourceType: AlarmDataSource) {
        
        deactivateButton.isHidden = true
        continueButton.isHidden = true
        messageInputView.isHidden = true
        
        switch dataSourceType {
        case .priority:
            alarmTableView.dataSource = priorityDataSource
            consoleDataSource.focusedCell = .priority
            if isInInitialSetup {
                navigationItem.title = "Larm utlöst"
                deactivateButton.isHidden = false
            } else {
                navigationItem.title = alarm?.alarmType?.name
                continueButton.isHidden = false
            }
        case .location:
            locationDataSource.location = .building
            alarmTableView.dataSource = locationDataSource
            consoleDataSource.focusedCell = .location
            continueButton.isHidden = false
            if isInInitialSetup {
                navigationItem.title = "Larm utlöst"
            } else {
                navigationItem.title = alarm?.alarmType?.name
            }
        case .communication:
            alarmTableView.dataSource = communicationDataSource
            navigationItem.title = alarm?.alarmType?.name
            consoleDataSource.focusedCell = nil
            messageInputView.isHidden = false
            isInInitialSetup = false
            reloadTableView(consoleTableView)
        }
        reloadTableView(alarmTableView)
    }
    
//    func addBackButton() {
//        let backButton = UIButton(type: .custom)
//        backButton.setImage(#imageLiteral(resourceName: "arrow_back").withRenderingMode(.alwaysOriginal), for: .normal)
//        backButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
//        backButton.imageView?.contentMode = .scaleAspectFit
//        backButton.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
//        let barButton = UIBarButtonItem(customView: backButton)
//        navigationController?.navigationItem.leftBarButtonItem = barButton
//    }
    
    func updateConsole(snapshot: DataSnapshot) {
        print("Received snapshot: ", snapshot.key)
        switch snapshot.key {
        case "priority":
            if let priority = snapshot.value as? NSDictionary {
                if  let name = priority["name"] as? String,
                    let level = priority["level"] as? Int {
                    self.alarm?.priority = Priority(name: name, priority: level)
                    reloadTableView(consoleTableView)
                }
            }
        case "isActive":
            self.alarm?.isActive = snapshot.value as? Bool
            reloadTableView(consoleTableView)
        case "location":
            if let locations = snapshot.childSnapshot(forPath: "room").value as? [String:Any?] {
                print(locations)
                var buildingName: String?
                var sectionName: String?
                var floorName: String?
                var roomDesc: (key: String, value: String)?
                for location in locations {
//                    print(location.key, ": ", location.value as? String)
                    switch location.key {
                    case "building":
                        buildingName = location.value as? String
                    case "section":
                        sectionName = location.value as? String
                    case "floor":
                        floorName = location.value as? String
                    case "room":
                        if let room = location.value as? NSDictionary {
                            if  let roomName = room["name"] as? String,
                                let descName = room["desc"] as? String {
                                roomDesc = (key: roomName, value: descName)
                            }
                        }
                    default: print("Unknown location-key")
                    }
                }
                self.alarm?.location = Location(building: buildingName, section: sectionName, floor: floorName, room: roomDesc, alarm: self.alarm)
                reloadTableView(consoleTableView)
            }
        default: print("Unknown snapshot-key: ", snapshot.key)
        }
    }
    
    func reloadTableView(_ tableView: UITableView?) {
        let indexSet = IndexSet(integer: .init(0))
        if tableView == consoleTableView {
            if (userIsAdmin || userIsAuthor) && alarmTableView.dataSource is CommunicationDataSource {
                UIView.animate(withDuration: 0.2, animations: {
                    self.consoleHeightConstraint.constant = 168
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.consoleHeightConstraint.constant = 126
                    self.view.layoutIfNeeded()
                })
            }
            consoleTableView.reloadSections(indexSet, with: .fade)
        } else {
            alarmTableView.reloadSections(indexSet, with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == consoleTableView {
            switch consoleDataSource.isInEditingMode {
            case true:
                switch indexPath.row {
                case Console.status.rawValue:
                    switch userIsAdmin && !userIsAuthor {
                    case true:
                        alarm?.isActive = false
                        alarm?.upload(false, childPath: "/isActive")
                    case false: break
                    }
                case Console.priority.rawValue:
                    switchDataSource(.priority)
                case Console.location.rawValue:
                    switchDataSource(.location)
                case Console.edit.rawValue: consoleDataSource.isInEditingMode = false
                default: break
                }
                consoleDataSource.isInEditingMode = false
            case false:
                switch indexPath.row {
                case Console.location.rawValue:
                    if alarm?.coordinates != nil {
                        showMap()
                    }
                case Console.edit.rawValue: consoleDataSource.isInEditingMode = true
                default: break
                }
            }
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? SetupCell else {
            return
        }
        switch tableView.dataSource {
        case is PriorityDataSource: selectPriority(cell.value as! Priority)
        case is LocationDataSource:
            switch locationDataSource.location {
            case .building?: locationDataSource.building = cell.value as? Building
            case .section?: locationDataSource.section = cell.value as? Section
            case .floor?: locationDataSource.floor = cell.value as? Floor
            case .room?: locationDataSource.room = cell.value as? Room
            default: break
            }
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == consoleTableView {
            return 42
        }
//        if tableView.cellForRow(at: indexPath) is HeaderCell {
//            return 24
//        }
        if let dataSource = alarmTableView.dataSource as? CommunicationDataSource {
            let arbitraryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 275, height: 34))
            arbitraryLabel.font = UIFont.systemFont(ofSize: 16)
            arbitraryLabel.numberOfLines = 0
            arbitraryLabel.text = dataSource.messages[indexPath.row].body
            let arbitraryLabelWidth: CGFloat = arbitraryLabel.frame.size.width
            let arbitraryLabelSize: CGSize = arbitraryLabel.sizeThatFits(CGSize(width: arbitraryLabelWidth, height: CGFloat(MAXFLOAT)))
            let marginHeight: CGFloat = 18 + 26
            return arbitraryLabelSize.height + marginHeight
        } else {
            // Set height for header
            var row: Int?
            switch tableView.dataSource {
            case is PriorityDataSource: row = priorityDataSource.priorities?.count
            case is LocationDataSource:
                switch locationDataSource.location! {
                case .building: row = locationDataSource.buildings.count
                case .section: row = locationDataSource.sections.count
                case .floor: row = locationDataSource.floors.count
                case .room: row = locationDataSource.rooms.count
                }
            default: break
            }
            if indexPath.row == row {
                return 26
            }
            return 52
        }
    }
    
//    func reloadTableView(_ tableView: UITableView) {
//        let range = NSMakeRange(0, tableView.numberOfSections)
//        let sectionsIndex: IndexSet = NSIndexSet(indexesIn: range) as IndexSet
//        tableView.reloadSections(sectionsIndex, with: .fade)
//    }
    
    func selectPriority(_ priority: Priority) {
        alarm?.priority = priority
        alarm?.upload(priority, childPath: "priority")
        isInInitialSetup ? switchDataSource(.location) : switchDataSource(.communication)
    }

    func showMap() {
        performSegue(withIdentifier: "Map", sender: alarm)
    }
    
    func goToMain() {
        if didLaunchFromRemoteNotification == true {
            print("LaunchedFromRemoteNotification")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.switchToMain(userId: me!.id!, completion: { (success, response, error) in
                guard success, error == nil else {
                    print("Switch to main fail")
                    return
                }
            })
        } else {
            if let nav = self.navigationController as? NavigationController {
                nav.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func deactivateAlarm(_ sender: DefaultButton) {
        alarm?.isActive = false
        alarm?.upload(alarm?.isActive, childPath: "isActive")
        goToMain()
    }
    
    @IBAction func continueButton(_ sender: DefaultButton) {
        switchDataSource(.communication)
    }
    
    @IBAction func sendMessageButton(_ sender: UIButton) {
        sendMessage(body: messageTextView.text!)
    }
    
    func sendMessage(body: String) {
        _ = Message(body: body, author: me!, alarm: alarm!)
        messageTextView.resignFirstResponder()
        messageTextView.text = ""
        adjustTextViewHeight(messageTextView, messageTextViewHeightConstraint)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AlarmDelegate {
            dest.alarm = alarm
            dest.me = me
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            removeKeyboardObservers()
            stopObserving()
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
}

public enum Console: Int {
    case status = 0
    case priority = 1
    case location = 2
    case edit = 3
}

extension AlarmViewController: KeyboardAvoidable {
    
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] {
        return [bottomConstraint]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension AlarmViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView, messageTextViewHeightConstraint)
        if textView.text != "" {
            messageTextViewPlaceholder.isHidden = true
        } else {
            messageTextViewPlaceholder.isHidden = false
        }
    }
    
    func adjustTextViewHeight(_ textView: UITextView, _ constraint: NSLayoutConstraint) {
        let textViewFixedWidth: CGFloat = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSize(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        let difference = newSize.height - textView.frame.size.height
        DispatchQueue.main.async {
            constraint.constant += difference
        }
    }
    
}


extension AlarmViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 && alarm != nil else {
            return
        }
        let location = locations.first!
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        alarm?.coordinates = [lat, lon]
        alarm?.upload(lat, childPath: "location/coordinates/lat")
        alarm?.upload(lon, childPath: "location/coordinates/lon")
        
        let time = Int(round(NSDate.timeIntervalSinceReferenceDate))
        
        if location.horizontalAccuracy < CLLocationAccuracy(20) || time > Int(alarm!.timestamp!) + 30 {
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension AlarmViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let main = viewController as? Unwindable {
            main.unwindFrom(alarm: alarm)
        }
    }
    
}
