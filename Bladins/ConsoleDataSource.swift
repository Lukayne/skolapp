//
//  ConsoleDataSource.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-19.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class ConsoleDataSource: NSObject, UITableViewDataSource {
    // Console tableView datasource
    
    var delegate: ConsoleDelegate!
    var focusedCell: Console?
    
    var isInEditingMode = false {
        didSet {
            delegate.reloadTableView(delegate?.consoleTableView)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (delegate.userIsAdmin || delegate.userIsAuthor) && delegate.alarmTableView.dataSource is CommunicationDataSource {
        case true: return 4
        case false: return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != Console.edit.rawValue else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditTableViewCell
            if isInEditingMode {
                cell.buttonLabel.text = "Avbryt"
            } else {
                cell.buttonLabel.text = "Ändra"
            }
            return cell
        }
        switch isInEditingMode {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditTableViewCell
            switch indexPath.row {
            case Console.status.rawValue:
                switch delegate.userIsAdmin && !delegate.userIsAuthor {
                case true: cell.buttonLabel.text = "Avaktivera larm"
                case false: cell.buttonLabel.text = "Begär avaktivering"
                }
            case Console.priority.rawValue:
                cell.buttonLabel.text = "Ändra prioritet"
            case Console.location.rawValue:
                cell.buttonLabel.text = "Ändra plats"
            default: break
            }
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as! StatusTableViewCell
            switch indexPath.row {
            case Console.status.rawValue:
                cell.keyText = "Status"
                if delegate.alarm?.isActive == true {
                    cell.valueText = "Aktivt"
                } else {
                    cell.valueText = "Inaktivt"
                }
            case Console.priority.rawValue:
                cell.keyText = "Prioritet"
                cell.valueText = delegate.alarm?.priority?.name
            case Console.location.rawValue:
                if delegate.alarm?.coordinates != nil {
                    cell.keyText = "Visa plats"
                } else {
                    cell.keyText = "Plats"
                }
                cell.valueLabel.text = delegate.alarm?.location?.locationDescription()
            default: break
            }
            if focusedCell != nil {
                if focusedCell?.rawValue == indexPath.row {
                    cell.setCellFocused(true)
                } else {
                    cell.setCellFocused(false)
                }
            } else {
                cell.setCellFocused(true)
            }
            return cell
        }
    }
    
}
