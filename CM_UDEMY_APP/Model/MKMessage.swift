//
//  MKMessage.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 16/12/20.
//

import Foundation
import MessageKit

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType {return mkSender}
    var senderInitials: String
    
    var photoItem: PhotoMessage?
    var status: String
    
    init(message: Message) {
        
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.senderInitials = message.senderInitials
        self.sentDate = message.sendDate
        self.incoming = FUser.currentId() != mkSender.senderId
    }
    
}
