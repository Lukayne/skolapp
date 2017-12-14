//
//  PriorityDataSource.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-04.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class PriorityDataSource: NSObject, AlarmTableViewDataSource {
    
    var delegate: AlarmViewControllerDelegate? {
        didSet {
            priorities = delegate?.alarm?.alarmType?.priorities
            priorities = priorities?.sorted { return $0.priority < $1.priority }
        }
    }
    
    var priorities: [Priority]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (priorities?.count ?? 0)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (tableView.numberOfRows(inSection: 0) - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
            cell.entry = "Ange prioritet"
            return cell
        }
        guard priorities != nil else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriorityCell", for: indexPath) as! SetupCell
        cell.value = priorities![priorities!.count - indexPath.row - 1]
        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
}
