//
//  CommunicationDataSource.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-04.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase


class CommunicationDataSource: NSObject, AlarmTableViewDataSource {
    
    var delegate: AlarmViewControllerDelegate? {
        didSet {
            startObserving()
        }
    }
    var messages = [Message]()
    var query: DatabaseQuery?
    
    func startObserving() {
        // The database reference is determined by the data of the alarm.
        let ref = Database.database().reference()
        let chatRef = ref.child("schools").child(delegate!.alarm!.school!.name!).child("alarms").child(delegate!.alarm!.id!).child("log")
        query = chatRef.queryLimited(toLast: 10)
        
        query?.observe(.childAdded, with: { [weak self] (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                _ = Message(id: snapshot.key, data: data, completion: { (success, response, error) in
                    guard success, let message = response as? Message else {
                        print(error ?? "Message error")
                        // SHOW ALERT
                        return
                    }
                    self?.didReceiveMessage(message: message)
                })
            } else {
                print("Failed to cast data")
            }
        })
    }
    
    func didReceiveMessage(message: Message) {
        messages.append(message)
        messages = messages.sorted { return $0.timestamp! > $1.timestamp! }
        delegate?.reloadTableView(nil)
        delegate?.alarmTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func stopObserving() {
        query?.removeAllObservers()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        if message.authorId == delegate?.me?.id {
            cell.messageType = MessageType.mine
        } else if message.authorId == delegate?.alarm?.authorId {
            cell.messageType = MessageType.author
        } else {
            cell.messageType = MessageType.others
        }
        cell.message = message
        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    func scrollTableViewToBottom(_ tableView: UITableView) {
        //        let scrollPoint = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.size.height)
        //        tableView.setContentOffset(scrollPoint, animated: true)
    }
    
}
