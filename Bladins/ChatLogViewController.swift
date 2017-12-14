////
////  ChatLogViewController.swift
////  Bladins
////
////  Created by Richard Smith on 2017-07-29.
////  Copyright © 2017 Richard Smith. All rights reserved.
////
//
//import UIKit
//import JSQMessagesViewController
//import FirebaseDatabase
//
//class ChatLogViewController: JSQMessagesViewController, AlarmDelegate {
//    
//    // Alarm and current user is passed to this viewcontroller
//    var alarm: Alarm?
//    var me: User?
//    
//    var chatRef: DatabaseReference?
//    var messages = [Message]()
//    
//    lazy var outgoingBubble: JSQMessagesBubbleImage = {
//        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//    }()
//    
//    lazy var incomingBubble: JSQMessagesBubbleImage = {
//        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        guard alarm != nil else {
//            return
//        }
//        
//        senderId = me?.id
//        senderDisplayName = me?.name
//        
//        // tar bort möjligheten till att lägga till bild och profilbild sätts till 0.
//        inputToolbar.contentView.leftBarButtonItem = nil
//        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
//        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
//        
//        
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        // The database reference is determined by the data of the alarm.
//        let ref = Database.database().reference()
//        chatRef = ref.child("schools").child(alarm!.author!.school!.name!).child("alarms").child(alarm!.id!).child("log")
//        let query = chatRef?.queryLimited(toLast: 10)
//        
//        query?.observe(.childAdded, with: { [weak self] (snapshot) in
//            if let data = snapshot.value as? NSDictionary {
//                _ = Message(id: snapshot.key, data: data, completion: { (success, response, error) in
//                    guard success, let message = response as? Message else {
//                        print(error ?? "No success")
//                        // SHOW ALERT
//                        return
//                    }
//                    self?.messages.append(message)
//                    self?.finishReceivingMessage()
//                })
//            } else {
//                print("Failed to cast data")
//            }
//        })
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
//        
//        let message = messages[indexPath.item]
//        let jsq = message.jsq()
//        return jsq!
//        
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        return messages.count
//        
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
//        
//        return messages[indexPath.item].author?.id == me?.id ? outgoingBubble : incomingBubble
//        
//    }
//    
//    // döljer avatarbild (profilbild)
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        
//        return nil
//        
//    }
//    
//    // Namn på sender, ifall det är "du" som skickar meddelande då är det nil = ingen text.
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//        
//        return messages[indexPath.item].author?.id == me?.id ? nil : NSAttributedString(string: (messages[indexPath.item].author?.name)!)
//        
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//        let timeString = messages[indexPath.item].timeString
//        let attrString = NSAttributedString(string: timeString!)
//        return attrString
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
//        return 10
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
//        
//        return messages[indexPath.item].author?.id == me?.id ? 0 : 15
//        
//    }
//    
//    // metod för att skicka ett meddelande
//    
//    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        
//        _ = Message(body: text, author: me!, alarm: alarm!)
//        finishSendingMessage()
//        
//    }
//
//}
