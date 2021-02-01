//
//  Message.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 16/12/20.
//

import Foundation
import Firebase

class Message {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var type = ""
    var isIncoming = false
    var sendDate = Date()
    var message = ""
    var photoWidth = 0
    var photoHeight = 0
    var senderInitials = ""
    var mediaURL = ""
    var status = ""
    
    var dictionary: NSDictionary{
        
        return NSDictionary(objects: [self.id,
                                      self.chatRoomId,
                                      self.senderId,
                                      self.senderName,
                                      self.type,
                                      self.sendDate,
                                      self.message,
                                      self.photoWidth,
                                      self.photoHeight,
                                      self.senderInitials,
                                      self.mediaURL,
                                      self.status
        ], forKeys:[KOBJECTID as NSCopying,
                    kCHATROOMID as NSCopying,
                    kSENDERID as NSCopying,
                    kSENDERNAME as NSCopying,
                    kTYPE as NSCopying,
                    kDATE as NSCopying,
                    kMESSAGE as NSCopying,
                    kPHOTOWIDTH as NSCopying,
                    kPHOTOHEIGHT as NSCopying,
                    kSENDERINITIALS as NSCopying,
                    kMEDIAURL as NSCopying,
                    kSTATUS as NSCopying
        ])
    }
    
    init() { }
    
    init(dictionary: [String : Any]) {
        
        id = dictionary[KOBJECTID] as? String ?? ""
        chatRoomId = dictionary[kCHATROOMID] as? String ?? ""
        senderId = dictionary[kSENDERID] as? String ?? ""
        senderName = dictionary[kSENDERNAME] as? String ?? ""
        type = dictionary[kTYPE] as? String ?? ""
        isIncoming = (dictionary[kSENDERID] as? String ?? "") != FUser.currentId()
        sendDate = (dictionary[kDATE] as? Timestamp)?.dateValue() ?? Date()
        message = dictionary[kMESSAGE] as? String ?? ""
        photoWidth = dictionary[kPHOTOWIDTH] as? Int ?? 0
        photoHeight = dictionary[kPHOTOHEIGHT] as? Int ?? 0
        senderInitials = dictionary[kSENDERINITIALS] as? String ?? ""
        mediaURL = dictionary[kMEDIAURL] as? String ?? ""
        status = dictionary[kSTATUS] as? String ?? ""
        
        
    }
}
