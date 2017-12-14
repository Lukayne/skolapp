//
//  User.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

class User {
    // There are two ways of instantiating a user. Create a new one and the data is uploaded to the database, or get one by id (i.e. when loggin in) and the variables are downloaded from the database.
    
    var id: String?
    var school: School?
    var name: String?
    var token: String?
    var isAdmin: Bool?
    var groupIds: [String]?
    
    // CREATE NEW USER
    init?(id: String?, school: String?, name: String?, completion: @escaping (Bool, Any?, Error?) -> Void) {
        guard id != nil && school != nil && name != nil else {
            completion(false, nil, nil)
            return nil
        }
        self.id = id
        self.school = School(name: school!)
        self.name = name
        self.token = Messaging.messaging().fcmToken!
        
        let ref = Database.database().reference()
        ref.child("users").child(id!).updateChildValues(["name":name!, "school":school!], withCompletionBlock: { (error, reference) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            completion(true, self, nil)
        })
        ref.child("schools/\(school!)/users/\(id!)").setValue(token)
        
    }
    
    // GET USER
    init?(id: String?, completion: @escaping (Bool, Any?, Error?) -> Void) {
        guard id != nil else {
            return nil
        }
        let ref = Database.database().reference()
        ref.child("users").child(id!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let user = snapshot.value as? NSDictionary {
                self.id = id
                self.name = user["name"] as? String
                self.isAdmin = user["isAdmin"] as? Bool
                if let school = user["school"] as? String {
                    self.school = School(name: school)
                }
                if let groups = user["groups"] as? [String:String] {
                    var groupIds = [String]()
                    for group in groups {
                        groupIds.append(group.value)
                    }
                    self.groupIds = groupIds
                }
                completion(true, self, nil)
                
            } else {
                completion(false, nil, nil)
            }
            
        }) { (error) in
            completion(false, nil, error)
        }
    }
    
    func updateGroups(completion: @escaping (Bool, Any?, Error?) -> Void) {
        let ref = Database.database().reference()
        let groupRef = ref.child("/users/\(id!)/groups")
        groupRef.removeValue { (error, ref) in
            guard error == nil, self.groupIds != nil else {
                completion(false, nil, error)
                return
            }
            for groupId in self.groupIds! {
                groupRef.childByAutoId().setValue(groupId)
            }
            completion(true, nil, nil)
        }
    }
    
}
