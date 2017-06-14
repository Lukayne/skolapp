//
//  Alert.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

class Alert {
    
    enum types: String {
        case threat
        case accident
        case intruder
        case other
    }
    
    var user: User?
    var timestamp: Int?
    var type: types? {
        didSet {
            print("did set")
            upload(values: ["type":type?.rawValue])
        }
    }
    var alarmRef: DatabaseReference?
    
    init(type: types, user: User) {
        print("Alarm initialized")
        
        self.type = type
        self.user = user
        self.timestamp = Int(round(NSDate.timeIntervalSinceReferenceDate))
        
        let ref = Database.database().reference()
        alarmRef = ref.child(user.school!).child("alerts").child(String(timestamp!))
        upload(values: ["type":type.rawValue])
        
    }
    
    func upload(values: [String:Any?]) {
        print("Upload ", values.count, " item/s")
        for value in values {
            print(value.key + " was uploaded")
            alarmRef?.child(value.key).setValue(value.value)
        }
        
    }
    
}
