//
//  School.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import FirebaseDatabase

class School {
    
    var name: String?
    var locations: [Location]?
    var alarmTypes: [AlarmType]?
    
    init(name: String) {
        self.name = name
    }
    
    func getLocations(completion: @escaping (Bool, Any?, Error?) -> Void) {
        let ref = Database.database().reference()
        ref.child("schools/\(name!)/settings/locations").observeSingleEvent(of: .value, with: {(snapshot) in
            if let locationsData = snapshot.valueInExportFormat() as? [String:[String:[String:[String:String]]]] {
                var locations = [Location]()
                for building in locationsData {
                    for section in building.value {
                        for floor in section.value {
                            for room in floor.value {
                                let location = Location(building: building.key, section: section.key, floor: floor.key, room: room, alarm: nil)
                                locations.append(location)
                            }
                        }
                    }
                }
                self.locations = locations
                completion(true, locations, nil)
            } else {
                print("Failed to cast")
                completion(false, nil, nil)
            }
            
        }, withCancel: { (error) in
            completion(false, nil, nil)
        })
        
    }
    
    func getAlarmOptions(completion: @escaping (Bool, Any?, Error?) -> Void) {
        let ref = Database.database().reference()
        ref.child("schools/\(name!)/settings/alarmTypes").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let data = snapshot.valueInExportFormat() as? [String:NSDictionary] else {
                print(snapshot.valueInExportFormat() ?? "Snapshot is nil")
                completion(false, nil, nil)
                return
            }
            var alarmTypes = [AlarmType]()
            for alarmData in data {
                if  let name = alarmData.value["name"] as? String,
                    let prioritiesData = alarmData.value["priorityOptions"] as? [String:Int] {
                    var priorities = [Priority]()
                    for priority in prioritiesData {
                        priorities.append(Priority(name: priority.key, priority: priority.value))
                    }
                    let alarmType = AlarmType(id: alarmData.key, name: name, priorities: priorities)
                    alarmTypes.append(alarmType)
                }
            }
            self.alarmTypes = alarmTypes
            completion(true, alarmTypes, nil)
            
        }, withCancel: { (error) in
            completion(false, nil, nil)
        })
    }
    
}
