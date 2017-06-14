//
//  User.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-06-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class User {
    var school: String?
    var email: String?
    var name: String?
    
    init(email: String, school: String, name: String) {
        self.email = email
        self.school = school
        self.name = name
    }
}
