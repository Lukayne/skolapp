//
//  Alert.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

class Alarm: Uploadable {
    // When a user creates an alarm, it creates an instance of this class. That instance is passed through the whole sequence of viewcontrollers and is always referred to when setting the variables.
    
    var newAlarmRef: DatabaseReference?
    var id: String?
    var authorId: String?
    var authorName: String?
    var school: School?
    var alarmType: AlarmType?
    var timestamp: Int?
    var timeString: String?
    var isActive: Bool?
    var priority: Priority?
    var coordinates: [Double]?
    var location: Location?
    
    // GET ALARM
    init(id: String, school: School, completion: @escaping (Bool, Any?, Error?) -> Void) {
        
        self.id = id
        self.school = school
        
        let ref = Database.database().reference()
        let alarmRef = ref.child("schools/\(school.name!)/alarms/\(id)")
        
        alarmRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if  let typeData = data["type"] as? String,
                    school.alarmTypes != nil {
                    for alarmType in school.alarmTypes! {
                        if alarmType.id == typeData {
                            self.alarmType = alarmType
                            break
                        }
                    }
                    if  let priorityData = data["priority"] as? NSDictionary {
                        if  let name = priorityData["name"] as? String,
                            let level = priorityData["level"] as? Int {
                            self.priority = Priority(name: name, priority: level)
                        }
                    }
                } else {
                    print("Couldn't get alarmoption: ", data["type"] ?? "nil")
                }
                self.isActive = data["isActive"] as? Bool
                self.authorId = data["authorId"] as? String
                self.authorName = data["authorName"] as? String
                self.timestamp = data["timestamp"] as? Int
                
                if let location = data["location"] as? NSDictionary {
                    if let roomLocation = location["room"] as? NSDictionary {
                        let location = Location(alarm: self)
                        if let building = roomLocation["building"] as? String {
                            location.building = Building(name: building)
                            if let section = roomLocation["section"] as? String {
                                location.section = Section(name: section, building: location.building!)
                                if let floor = roomLocation["floor"] as? String {
                                    location.floor = Floor(name: floor, section: location.section!)
                                    if  let room = roomLocation["room"] as? NSDictionary {
                                        if  let name = room["name"] as? String,
                                            let desc = room["desc"] as? String {
                                            location.room = Room(name: name, desc: desc, floor: location.floor!)
                                        }
                                    }
                                }
                            }
                        }
                        self.location = location
                    }
                    if let coordinates = location["coordinates"] as? NSDictionary,
                        let lat = coordinates["lat"] as? Double,
                        let lon = coordinates["lon"] as? Double {
                        self.coordinates = [lat, lon]
                    }
                }
                if self.authorId != nil, self.isActive != nil, self.timestamp != nil {
                    completion(true, self, nil)
                } else {
                    completion(false, nil, nil)
                }
            } else {
                completion(false, nil, nil)
            }
            
        }, withCancel: {(error) in
            print(error.localizedDescription)
            completion(false, nil, error)
        })
    }
    
    // NEW ALARM
    init?(alarmType: AlarmType, author: User?) {
        // If there is not enough information when attempting to initialize the alarm, it will fail and return nil.
        
        guard author != nil else {
            return nil
        }
        
        guard author!.school?.name != nil else {
            return nil
        }
        
        self.location = Location(alarm: self)
        self.isActive = true
        self.alarmType = alarmType
        self.authorId = author?.id
        self.authorName = author?.name
        self.school = author?.school
        
        // The timestamp is number of seconds since reference date
        self.timestamp = Int(round(NSDate.timeIntervalSinceReferenceDate))
        
        let ref = Database.database().reference().child("schools").child(author!.school!.name!).child("alarms")
        newAlarmRef = ref.childByAutoId()
        // The id is the unique childByAutoId
        self.id = newAlarmRef?.key
        
        let values: [String:Any?] = ["isActive": isActive, "type": alarmType.id, "timestamp":timestamp!, "authorName": authorName, "authorId": authorId]
        newAlarmRef?.setValue(values)
        
    }
    
    func upload(_ value: Any?, childPath: String) {
        if let priorityData = value as? Priority {
            newAlarmRef?.child("/\(childPath)/name").setValue(priorityData.name)
            newAlarmRef?.child("/\(childPath)/level").setValue(priorityData.priority)
            return
        }
        newAlarmRef?.child(childPath).setValue(value)
    }
    
    func getTimeString() {
        guard timestamp != nil else {
            return
        }
        let interval = TimeInterval(timestamp!)
        let date = Date(timeIntervalSinceReferenceDate: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.timeString = dateFormatter.string(from: date)
    }
    
}
