//
//  ChatEntryCell.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-08-21.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit

enum MessageType: Int {
    case log = 0
    case mine = 1
    case author = 2
    case others = 3
}

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageView: MessageView!
    @IBOutlet weak var timeLabel: DefaultLabel!
    @IBOutlet weak var bodyLabel: DefaultLabel!
    @IBOutlet weak var authorLabel: DefaultLabel!
    @IBOutlet var messageViewHeightConstraint: NSLayoutConstraint!
    
    var messageType: MessageType? {
        didSet {
            messageView.messageType = messageType!
        }
    }
    
    var message: Message? {
        didSet {
            
            // SET LABELS
            timeLabel.text = message?.timeString
            bodyLabel.text = message?.body
            authorLabel.text = message?.authorName
            
            // <- CHECK IF LOG MESSAGE
            
            setupView()
            
        }
    }
    
    func setupView() {
        backgroundColor = nil
        adjustMessageViewHeight()
    }
    
    func adjustMessageViewHeight() {
        let bodyLabelWidth: CGFloat = bodyLabel.frame.size.width
        let bodyLabelSize: CGSize = bodyLabel.sizeThatFits(CGSize(width: bodyLabelWidth, height: CGFloat(MAXFLOAT)))
        let marginHeight: CGFloat = 18
        DispatchQueue.main.async {
            self.messageViewHeightConstraint.constant = bodyLabelSize.height + marginHeight
        }
    }
    
}
