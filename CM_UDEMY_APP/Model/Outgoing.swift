//
//  Outgoing.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 17/12/20.
//

import Foundation
import UIKit

class Outgoing {
    
    var messageDictionary: [String : Any]
    
//    MARK: initializer
    init(message: Message, text: String, memberIds: [String]) {
        
        
        message.type = kTEXT
        message.message = text
        
        messageDictionary = message.dictionary as! [String : Any]
    }
    
    //--init for picutre
    init(message: Message, photo: UIImage, photoURL: String, memberIds: [String]) {
        
        message.type = kPICTURE
        message.message = "Picture Message"
        
        message.photoWidth = Int(photo.size.width)
        message.photoHeight = Int(photo.size.height)
        
        message.mediaURL = photoURL
        
        messageDictionary = message.dictionary as! [String : Any]
    }
    
    class func send(chatId: String, text: String?, photo: UIImage?, memberIds: [String]){
        
        let currentUser = FUser.currentUser()!
        
        let message = Message()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.objectId
        message.senderName = currentUser.username
        message.sendDate = Date()
        message.senderInitials = String(currentUser.username.first!)//String(currentUser.username.first!)
        message.status = kSENT
        message.message = text ?? "picture message"
     
        if text != nil {
            let outgoingMessage = Outgoing(message: message, text: text!, memberIds: memberIds)

            outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
        } else {
            
            if photo != nil {
                
                let fileName = Date().stringDate()
                let fileDirectory = "MediaMessages/Photo" + "\(chatId)/" + "_\(fileName)" + "jpg"
                
                FileStorage.saveImageLocally(imageData: photo!.jpegData(compressionQuality: 0.6) as! NSData , fileName: fileName)
                FileStorage.uploadImage(photo!, directory: fileDirectory) { (imageURL) in
                    
                    if imageURL != nil {
                        
                        let outgoingMessage = Outgoing(message: message, photo: photo!, photoURL: imageURL!, memberIds: memberIds)
                        
                        outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
                    }
                }
            }
        }
        
        PushNotificationService.shared.sendPushNotificationTo(userId: removeCurrentUserId(userIds: memberIds), body: message.message)
        
        FireBaseListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
    }

    func sendMessage(chatRoomId:String, messageId: String, memberIds: [String]) {
        
        for userId in memberIds {
            
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(messageId).setData(messageDictionary)
        }
    }

    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD] as [String : Any]
        
        for userId in memberIds {
            
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
            
        }
        
    }
    
    
    
}
