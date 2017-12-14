//
//  GroupsTableViewCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    let defaultTextColor = Color.custom(hexString: "161616", alpha: 1).value
    
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = defaultTextColor
        }
    }
    @IBOutlet var membersLabel: UILabel! {
        didSet {
            membersLabel.textColor = defaultTextColor
        }
    }
    @IBOutlet var selectedView: UIImageView!
    
    var group: Group? {
        didSet {
            guard group != nil else {
                return
            }
            nameLabel.text = group!.name
            var memberText = ""
            switch group!.memberCount {
            case 1: memberText = "1 medlem"
            case 1..<Int.max: memberText = "\(String(group!.memberCount)) medlemmar"
            default: memberText = "Inga medlemmar"
            }
            membersLabel.text = memberText
        }
    }
    
    var selectedGroup: Bool? {
        didSet {
            guard oldValue != selectedGroup else {
                return
            }
            if selectedGroup == true {
                UIView.transition(with: self.selectedView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.selectedView.image = #imageLiteral(resourceName: "isSelected")
                })
            } else {
                UIView.transition(with: self.selectedView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.selectedView.image = #imageLiteral(resourceName: "notSelected")
                })
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedGroup = false
    }
    
}
