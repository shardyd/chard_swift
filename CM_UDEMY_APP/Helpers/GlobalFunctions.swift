//
//  GlobalFunctions.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 09/12/20.
//

import Foundation
import Firebase

//MARK: match
func removeCurrentUserId(userIds: [String]) -> [String] {
    var allIds = userIds
    
    for id in allIds {
        if id == FUser.currentId() {
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
    }

    return allIds
}

//MARK: save like
func saveLikeToUser(userId: String) {
    
    let like = LikeObject(id: UUID().uuidString, userId: FUser.currentId(), likedUserId: userId, date: Date())
    like.saveToFireStore()
    
    if let currentUser = FUser.currentUser() {
        
        if !didLikeUserWith(userId: userId) {
            
            currentUser.likedIdArray!.append(userId)
            
            currentUser.updateCurrentUserInFireStore(withValues: [KLIKEDIDARRAY: currentUser.likedIdArray!]) { (error) in
                
                print("update current user with error ", error?.localizedDescription)
            }
        }
    }
    
    
}

//MARK: likes
func didLikeUserWith (userId: String) -> Bool {
    
    return FUser.currentUser()?.likedIdArray?.contains(userId) ?? false
}

//MARK: Start chat
func startChat(user1: FUser, user2: FUser) -> String {
    
    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? user1Id + user2Id : user2Id + user1Id
    
    return chatRoomId
    
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    
    FireBaseListener.shared.downloadUsersFromFireBase(withIds: memberIds) { (users) in
        
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

//MARK: recent chats

func createRecentItems(chatRoomId: String, users: [FUser]) {
    
    var memberIdsToCreateRecent: [String] = []
    
    for user in users {
        memberIdsToCreateRecent.append(user.objectId)
    }

    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        
        for userId in memberIdsToCreateRecent {
            
            let senderUser = userId == FUser.currentId() ? FUser.currentUser()! : getReceiverFrom(users: users)
            let receiverUser = userId == FUser.currentId() ? getReceiverFrom(users: users) : FUser.currentUser()!
            
            let recentObject = RecentChat()
            
            recentObject.objectId = UUID().uuidString
            recentObject.chatRoomId = chatRoomId
            recentObject.senderId = senderUser.objectId
            recentObject.senderName = senderUser.username
            recentObject.receiverId = receiverUser.objectId
            recentObject.receiverName = receiverUser.username
            recentObject.date = Date()
            recentObject.memberIds = [senderUser.objectId, receiverUser.objectId]
            recentObject.lastMessage = ""
            recentObject.unreadCounter = 0
            recentObject.avatarLink = receiverUser.avatarLink

            recentObject.saveToFireStore()
        }
    }
    
    
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    
    var memberIdsToCreateRecent = memberIds
    
    for recentData in snapshot.documents {
        
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserId = currentRecent[kSENDERID] {
            
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    
    return memberIdsToCreateRecent
}

func getReceiverFrom(users: [FUser]) -> FUser {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: FUser.currentUser()!)!)
    
    return allUsers.first!
    
}

func isLookingForMale() -> Bool {
    return FUser.currentUser()?.lookingFor == "Male"
}
