//
//  Room.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-25.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

protocol Uploadable: class {
    func upload(_ value: Any?, childPath: String)
}

class Location {
    
    var alarm: Uploadable?
    
    var building: Building? {
        didSet {
            section = nil
        }
    }
    var section: Section? {
        didSet {
            floor = nil
        }
    }
    var floor: Floor? {
        didSet {
            room = nil
        }
    }
    var room: Room?
    
    init() { }
    
    init(alarm: Uploadable) {
        self.alarm = alarm
    }
    
    init(building: String?, section: String?, floor: String?, room: (key: String, value: String)?, alarm: Uploadable?) {
        self.alarm = alarm
        if let buildingName = building {
            self.building = Building(name: buildingName)
            if let sectionName = section {
                self.section = Section(name: sectionName, building: self.building!)
                if let floorName = floor {
                    self.floor = Floor(name: floorName, section: self.section!)
                    if let roomName = room {
                        self.room = Room(name: roomName.key, desc: roomName.value, floor: self.floor!)
                    }
                }
            }
        }
    }
    
    func locationDescription() -> String {
        var locationText = ""
        if let bstr = building?.name {
            locationText.append(bstr)
            if let rstr = room?.name {
                locationText.append(", " + rstr)
                if let dstr = room?.desc {
                    locationText.append(" - " + dstr)
                }
            } else {
                if let sstr = section?.name {
                    locationText.append(", sektion " + sstr)
                }
                if let fstr = floor?.name {
                    locationText.append(", våning " + fstr)
                }
            }
        }
        return locationText
    }
    
    func upload() {
        print(alarm ?? "Error! no alarm uploadable")
        alarm?.upload(building?.name, childPath: "location/room/building")
        alarm?.upload(section?.name, childPath: "location/room/section")
        alarm?.upload(floor?.name, childPath: "location/room/floor")
        alarm?.upload(room?.name, childPath: "location/room/room/name")
        alarm?.upload(room?.desc, childPath: "location/room/room/desc")
//        if building != nil {
//            alarm?.upload(building?.name, childPath: "location/room/building") }
//        if section != nil {
//            alarm?.upload(section?.name, childPath: "location/room/section") }
//        if floor != nil {
//            alarm?.upload(floor?.name, childPath: "location/room/floor") }
//        if room != nil {
//            alarm?.upload(room?.name, childPath: "location/room/room/name")
//            alarm?.upload(room?.desc, childPath: "location/room/room/desc") }
    }
    
}

struct Building: Equatable {
    var name: String
    static func ==(lhs: Building, rhs: Building) -> Bool {
        if lhs.name == rhs.name {
            return true
        } else {
            return false
        }
    }
}

struct Section: Equatable {
    var name: String
    var building: Building
    static func ==(lhs: Section, rhs: Section) -> Bool {
        if  lhs.name == rhs.name,
            lhs.building == rhs.building {
            return true
        } else {
            return false
        }
    }
}

struct Floor: Equatable {
    var name: String
    var section: Section
    static func ==(lhs: Floor, rhs: Floor) -> Bool {
        if  lhs.name == rhs.name,
            lhs.section == rhs.section {
            return true
        } else {
            return false
        }
    }
}

struct Room: Equatable {
    var name: String
    var desc: String
    var floor: Floor
    static func ==(lhs: Room, rhs: Room) -> Bool {
        if  lhs.name == rhs.name,
            lhs.floor == rhs.floor {
            return true
        } else {
            return false
        }
    }
}

//struct Building: Uploadable {
//    var name: String
//    init?(_ building: String?) {
//        guard let parameter = building else {
//            return nil
//        }
//        self.name = parameter
//    }
//    func upload(reference: DatabaseReference?) {
//        reference?.child("building").setValue(name)
//    }
//}
//
//struct Section: Uploadable {
//    var name: String
//    var building: Building
//    init?(_ section: String?, building: Building?) {
//        guard let parameter = section, building != nil else {
//            return nil
//        }
//        self.name = parameter
//        self.building = building!
//    }
//    func upload(reference: DatabaseReference?) {
//        reference?.child("section").setValue(name)
//    }
//}
//
//struct Floor: Uploadable {
//    var name: String
//    var section: Section
//    init?(_ floor: String?, section: Section?) {
//        guard let parameter = floor, section != nil else {
//            return nil
//        }
//        self.name = parameter
//        self.section = section!
//    }
//    func upload(reference: DatabaseReference?) {
//        reference?.child("floor").setValue(name)
//    }
//}
//
//struct Room: Uploadable {
//    var name: String
//    var floor: Floor
//    init?(_ room: String?, floor: Floor?) {
//        guard let parameter = room, floor != nil else {
//            return nil
//        }
//        self.name = parameter
//        self.floor = floor!
//    }
//    func upload(reference: DatabaseReference?) {
//        reference?.child("room").setValue(name)
//    }
//}
