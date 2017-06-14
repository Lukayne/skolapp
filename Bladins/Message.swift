//
//  Message.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

protocol Uploadable {
    var objectRef: DatabaseReference? { get }
    func upload(_ data: [String:Any?])
}

extension Uploadable {
    func upload(_ data: [String:Any?]) {
        
    }
}

class NewMessage: Message, Uploadable {
    
    var objectRef: DatabaseReference?
    
    override init(body: String, author: User, alert: Alert) {
        
        // Create database reference
        let ref = Database.database().reference()
        objectRef = ref.child(author.school!).child("alerts").child(String(alert.timestamp!)).child("messages").child(String(timestamp!))
        
    }
    
    init(<#parameters#>) {
        <#statements#>
    }
    
}

class Message {
    
    var body: String?
    var timestamp: Int?
    var author: User?
    var alert: Alert?
    
    init(body: String, author: User, alert: Alert) {
        
        self.body = body
        self.author = author
        timestamp = Int(round(NSDate.timeIntervalSinceReferenceDate))
        
    }
    
    
}
