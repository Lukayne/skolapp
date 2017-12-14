//: Playground - noun: a place where people can play

import UIKit

var locations: NSDictionary? {
    return ["Alfa-hus":["A":["1":["A101", "A102"], "2":["A201", "A202"]], "B":["1":["B101", "B102"], "2":["B201", "B202"]]], "Beta-hus":["C":["1":["A101", "A102"], "2":["A201", "A202"]], "D":["1":["B101", "B102"], "2":["B201", "B202"]]]]
}

func getBuildings() -> [String] {
    return locations?.allKeys as! [String]
}

let buildings = getBuildings()

func getSectionsFor(building: String) -> [String]? {
    let houses = locations![building] as! NSDictionary
    let sections = houses.allKeys as! [String]
    return sections
}

let sectionsForA = getSectionsFor(building: buildings[0])

