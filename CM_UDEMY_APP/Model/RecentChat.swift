//
//  RecentChat.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 16/12/20.
//

import Foundation
import UIKit
import Firebase

class RecentChat {
    
    var objectId = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
    var avatar: UIImage?
    
    var dictionary: NSDictionary{
        
        return NSDictionary(objects: [self.objectId,
                                      self.chatRoomId,
                                      self.senderId,
                                      self.senderName,
                                      self.receiverId,
                                      self.receiverName,
                                      self.date,
                                      self.memberIds,
                                      self.lastMessage,
                                      self.unreadCounter,
                                      self.avatarLink
        ], forKeys: [KOBJECTID as NSCopying,
                     kCHATROOMID as NSCopying,
                     kSENDERID as NSCopying,
                     kSENDERNAME as NSCopying,
                     kRECEIVERID as NSCopying,
                     kRECEIVERNAME as NSCopying,
                     kDATE as NSCopying,
                     kMEMBERIDS as NSCopying,
                     kLASTMESSAGE as NSCopying,
                     kUNREADCOUNTER as NSCopying,
                     KAVATARLINK as NSCopying
        ])
    }
    
    init() {
        
    }
    
    
    init(_ recentDocument: Dictionary<String, Any>) {
        
        objectId = recentDocument[KOBJECTID] as? String ?? ""
        chatRoomId = recentDocument[kCHATROOMID] as? String ?? ""
        senderId = recentDocument[kSENDERID] as? String ?? ""
        senderName = recentDocument[kSENDERNAME] as? String ?? ""
        receiverId = recentDocument[kRECEIVERID] as? String ?? ""
        receiverName = recentDocument[kRECEIVERNAME] as? String ?? ""
        date = (recentDocument[kDATE] as? Timestamp)?.dateValue() ?? Date()
        memberIds = recentDocument[kMEMBERIDS] as? [String] ?? [""]
        lastMessage = recentDocument[kLASTMESSAGE] as? String ?? ""
        unreadCounter = recentDocument[kUNREADCOUNTER] as? Int ?? 0
        avatarLink = recentDocument[KAVATARLINK] as? String ?? ""

    }
    
    //MARK: saving
    func saveToFireStore() {
        
        FirebaseReference(.Recent).document(self.objectId).setData(self.dictionary as! [String : Any])
    }
    
    func deleteRecent() {
        
        FirebaseReference(.Recent).document(self.objectId).delete()
    }
}
