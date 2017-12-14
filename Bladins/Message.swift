//
//  Message.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

//protocol Uploadable: class {
//    var messageRef: DatabaseReference? { get }
//    func upload(values: [String:Any?], reference: DatabaseReference?)
//}
//
//extension Uploadable {
//    func upload(values: [String:Any?], reference: DatabaseReference?) {
//        print("Upload ", values.count, " item/s")
//        reference?.setValue(values)
//    }
//}

class Message {
    
    var id: String?
    var body: String?
    var timestamp: Int?
    var timeString: String?
    var authorId: String?
    var authorName: String?
    var alarm: Alarm?
    
    // GET MESSAGE
    init?(id: String?, data: NSDictionary?, completion: @escaping (Bool, Any?, Error?) -> Void) {
        guard id != nil, let dict = data else {
            completion(false, nil, nil)
            return nil
        }
        self.id = id
        self.body = dict["body"] as? String
        if let timestamp = dict["timestamp"] as? Int {
            self.timestamp = timestamp
            self.timeString = getTimeString(from: timestamp)
        }
        self.authorId = dict["authorId"] as? String
        self.authorName = dict["authorName"] as? String
        completion(true, self, nil)
    }
    
    // NEW MESSAGE
    init?(body: String, author: User, alarm: Alarm) {
        
        guard author.name != nil, body != "" else {
            print("Failed to initialize Message")
            return nil
        }
        
        // Create database reference
        let ref = Database.database().reference()
        let messageRef = ref.child("schools").child(author.school!.name!).child("alarms").child(alarm.id!).child("log").childByAutoId()
        
        self.id = messageRef.key
        self.body = body
        self.timestamp = Int(round(NSDate.timeIntervalSinceReferenceDate))
        self.timeString = getTimeString(from: timestamp!)
        self.authorId = author.id
        self.authorName = author.name
        self.alarm = alarm
        
        let values: [String:Any?] = ["body":body, "timestamp":timestamp, "authorId":author.id, "authorName":author.name, "alarm":alarm.id]
        messageRef.setValue(values)
        
    }
    
    func getTimeString(from: Int) -> String {
        let interval = TimeInterval(timestamp!)
        let date = Date(timeIntervalSinceReferenceDate: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
}
