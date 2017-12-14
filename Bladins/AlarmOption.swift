//
//  AlarmType.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-20.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import Foundation

struct AlarmType {
    var id: String
    var name: String
    var priorities: [Priority]
}

struct Priority {
    var name: String
    var priority: Int
}
