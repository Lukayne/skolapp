//
//  LocationDataSource.swift
//  Bladins
//
//  Created by Richard Smith on 2017-06-14.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class LocationDataSource: NSObject, AlarmTableViewDataSource {
    
    enum SelectedLocation: Int {
        case building = 0
        case section = 1
        case floor = 2
        case room = 3
        var label: String {
            switch self {
            case .building: return "Byggnad"
            case .section: return "Sektion"
            case .floor: return "Våning"
            case .room: return "Sal"
            }
        }
    }
    
    var delegate: AlarmViewControllerDelegate? {
        didSet {
            // The user is set by ContainerViewController. When set, it looks for the locations of the user's school and imports it to the local variable 'locations'.
            guard let schoolLocations = delegate?.me?.school?.locations else {
                delegate?.me?.school?.getLocations(completion: { (success, response, error) in
                    guard success else {
                        self.close()
                        return
                    }
                    self.locations = self.delegate?.me?.school?.locations
                })
                return
            }
            locations = schoolLocations
        }
    }
    
    var location: SelectedLocation? {
        didSet {
            delegate?.reloadTableView(nil)
            if location == .room, rooms.count > 0 {
                delegate?.alarmTableView.scrollToRow(at: IndexPath(row: self.rooms.count, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    // The 'locations' dictionary organizes all rooms in the right place.
    var locations: [Location]? {
        didSet {
            guard locations != nil else {
                return
            }
            var keys = [Building]()
            for each in locations! {
                if !keys.contains(each.building!) {
                    keys.append(each.building!)
                }
            }
            buildings = keys.sorted{ return $0.name < $1.name }.reversed()
            location = .building
        }
    }
    
    
    var buildings = [Building]()
    var sections = [Section]()
    var floors = [Floor]()
    var rooms = [Room]()
    
    var building: Building? {
        didSet {
            section = nil
            delegate?.alarm?.location?.building = building
            guard building != nil else {
                return
            }
            delegate?.alarm?.location?.upload()
            var keys = [Section]()
            for each in locations! {
                if each.section!.building == building! {
                    var alreadyContains = false
                    for key in keys {
                        if each.section! == key {
                            alreadyContains = true
                        }
                    }
                    if !alreadyContains {
                        keys.append(each.section!)
                    }
                }
            }
            sections = keys.sorted{ return $0.name < $1.name}.reversed()
            floors = [Floor]()
            rooms = [Room]()
            location = .section
        }
    }
    var section: Section? {
        didSet {
            floor = nil
            delegate?.alarm?.location?.section = section
            guard section != nil else {
                return
            }
            delegate?.alarm?.location?.upload()
            var keys = [Floor]()
            for each in locations! {
                if each.floor?.section == section {
                    var alreadyContains = false
                    for key in keys {
                        if each.floor! == key {
                            alreadyContains = true
                        }
                    }
                    if !alreadyContains {
                        keys.append(each.floor!)
                    }
                }
            }
            floors = keys.sorted{ return $0.name < $1.name}.reversed()
            rooms = [Room]()
            location = .floor
        }
    }
    var floor: Floor? {
        didSet {
            room = nil
            delegate?.alarm?.location?.floor = floor
            guard floor != nil else {
                return
            }
            delegate?.alarm?.location?.upload()
            var keys = [Room]()
            for each in locations! {
                if each.room?.floor == floor {
                    var alreadyContains = false
                    for key in keys {
                        if each.room! == key {
                            alreadyContains = true
                        }
                    }
                    if !alreadyContains {
                        keys.append(each.room!)
                    }
                }
            }
            rooms = keys.sorted{ return $0.name < $1.name}.reversed()
            location = .room
        }
    }
    var room: Room? {
        didSet {
            delegate?.alarm?.location?.room = room
            guard room != nil else {
                return
            }
            delegate?.alarm?.location?.upload()
            close()
        }
    }
    
    func close() {
        delegate?.switchDataSource(.communication)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch location {
        case .building?: return buildings.count + 1
        case .section?: return sections.count + 1
        case .floor?: return floors.count + 1
        case .room?: return rooms.count + 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (tableView.numberOfRows(inSection: 0) - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            switch location! {
            case .building:
                cell.entry = "Ange byggnad"
            case .section:
                cell.entry = "Ange sektion"
            case .floor:
                cell.entry = "Ange våning"
            case .room:
                cell.entry = "Ange sal"
            }
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! SetupCell
        switch location {
        case .building?: cell.value = buildings[indexPath.row]
        case .section?: cell.value = sections[indexPath.row]
        case .floor?: cell.value = floors[indexPath.row]
        case .room?: cell.value = rooms[indexPath.row]
        default: break
        }
        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }

}
