//
//  Group.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

struct Group: Equatable {
    var id: String
    var name: String
//    var school: School
    var memberCount: Int
    
    init?(id: String, data: NSDictionary) {
        guard   let name = data["name"] as? String else {
            print("Error! Couldn't get group")
            return nil
        }
        self.id = id
        self.name = name
        if let memberCount = (data["members"] as? NSDictionary)?.count {
            self.memberCount = memberCount
        } else {
            self.memberCount = 0
        }
    }
    static func ==(lhs: Group, rhs: Group) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
}
