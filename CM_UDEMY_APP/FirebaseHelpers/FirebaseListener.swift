//
//  FirebaseListener.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 27/11/20.
//

import Foundation
import Firebase

class FireBaseListener {
    
    static let shared = FireBaseListener()
    
    private init() {}

    //Mark: -FUser
    func downloadCurrentUserFromFirebase(userId: String, email: String) -> Void {
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            if snapshot.exists {
                let user = FUser(_dicitionary: snapshot.data() as! NSDictionary)
                user.saveUserLocally()
                user.getUserAvatarFromFirestore { (didSet) in
                }
            } else {
                //--first login
                if let user = userDefaults.object(forKey: KCURRENTUSER){
                    FUser(_dicitionary: user as! NSDictionary).saveUserToFireStore()
                }
            }
        }
    }
    
    //--busca usuarios do firebase
    func downloadUsersFromFirebase(isInitialLoad: Bool, limit: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping(_ users: [FUser], _ snapshot: DocumentSnapshot?) -> Void) {
        
        var query: Query!
        var users: [FUser] = []
        
        let ageFrom = Int(userDefaults.object(forKey: kAGEFROM) as? Float ?? 18.0)
        let ageTo = Int(userDefaults.object(forKey: kAGETO) as? Float ?? 50.0)

        if isInitialLoad {
            query = FirebaseReference(.User).whereField(kAGE, isGreaterThan: ageFrom).whereField(kAGE, isLessThan: ageTo).whereField(KISMALE, isEqualTo: isLookingForMale()).limit(to: limit)

            print("first \(limit) users download")
            
        } else {
            
            if lastDocumentSnapshot != nil {
                
                query = FirebaseReference(.User).whereField(kAGE, isGreaterThan: ageFrom).whereField(kAGE, isLessThan: ageTo).whereField(KISMALE, isEqualTo: isLookingForMale()).limit(to: limit).start(afterDocument: lastDocumentSnapshot!)
                
                print("next \(limit) user loading")
            } else {
                
                print("last snapshot is nil")
            }
        }
        
        //--chamar query
        if query != nil {
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                if !snapshot.isEmpty {
                    
                    for userData in snapshot.documents {
                        
                        let userObject = userData.data() as NSDictionary
                        
                        if !(FUser.currentUser()?.likedIdArray?.contains(userObject[KOBJECTID] as! String) ?? false) && FUser.currentId() != userObject[KOBJECTID] as! String {
                            
                            users.append(FUser(_dicitionary: userObject))
                        }
                    }

                    completion(users, snapshot.documents.last!)
                    
                } else {
                    print("no more users to fetch")
                    completion(users, nil)
                }
            }

        } else {
            
            completion(users, nil)
        }
        
    }
    
    func downloadUsersFromFireBase(withIds: [String], completion: @escaping (_ users: [FUser]) ->Void){
        
        var usersArray: [FUser] = []
        var counter = 0
        
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                if snapshot.exists {
                    
                    let user = FUser(_dicitionary: snapshot.data()! as NSDictionary)
                    usersArray.append(user)
                    
                    counter += 1
                    
                    if (counter == withIds.count){
                        completion(usersArray)
                    }
                } else {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: likes
    func downloadUserLikes(completion: @escaping(_ likeUserIds: [String]) -> Void) {
        
        FirebaseReference(.like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            
            var allLikedIds: [String] = []
            guard let snapshot = snapshot else {
                
                return
            }
     
            if !snapshot.isEmpty {
                for likeDictionary in snapshot.documents {
                    allLikedIds.append(likeDictionary[kUSERID] as? String ?? "")
                }
                completion(allLikedIds)
            } else {
                print("no likes found")
                completion(allLikedIds)
            }
        }
    }

    
    func checkIfUserLikedUs(userId: String, completion: @escaping(_ didLike: Bool) -> Void) {
        
        FirebaseReference(.like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).whereField(kUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            completion(!snapshot.isEmpty)
        }
        
    }
    
    //MARK: match
    func downloadUserMatches(completion: @escaping(_ matchedUsersId: [String]) -> Void) {
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        FirebaseReference(.Match).whereField(kMEMBERIDS, arrayContains: FUser.currentId()).whereField(kDATE, isGreaterThan: lastMonth).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
            
            var allMatchedIds: [String] = []
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                for matchDictionary in snapshot.documents {
                    
                    allMatchedIds += matchDictionary[kMEMBERIDS] as? [String] ?? [""]
                }
                
                completion(removeCurrentUserId(userIds: allMatchedIds))
                
            } else {
                print("no matches found")
                completion(allMatchedIds)
            }
        }
    }
    
    
    func saveMatch(userId: String) {
        
        let macth = MatchObject(id: UUID().uuidString, memberIds: [FUser.currentId(), userId], date: Date())
        
        macth.saveToFireStore()
    }


    //MARK: recent Chat
    func downloadRecentChatFromFireStore(completion: @escaping(_ allRecents: [RecentChat]) -> Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: FUser.currentId()).addSnapshotListener { (querySnapshot, error) in
            
            var recentChats: [RecentChat] = []
            
            guard let snapshot = querySnapshot else {return}
            
            if !snapshot.isEmpty {
                
                for recentDocument in snapshot.documents {
                    
                    if recentDocument[kLASTMESSAGE] as! String != "" && recentDocument[kCHATROOMID] != nil && recentDocument[KOBJECTID] != nil{
                        
                        let recent = RecentChat(recentDocument.data())
                        recentChats.append(recent)
                        
                    }
                }
                
                recentChats.sort(by: {$0.date > $1.date })
                completion(recentChats)
            } else {

                completion(recentChats)
            }
        }
        
    }

    func  updateRecents(chatRoomId: String, lastMessage: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let recentChat = RecentChat(recent.data())
                    
                    self.updateRecentItem(recent: recentChat, lastMessage: lastMessage)
                }
            }
        }
    }
    
    private func updateRecentItem(recent: RecentChat, lastMessage: String) {
        
        if recent.senderId != FUser.currentId() {
            recent.unreadCounter += 1
        }
        
        let values = [kLASTMESSAGE : lastMessage, kUNREADCOUNTER: recent.unreadCounter, kDATE: Date()] as [String: Any]
        
        FirebaseReference(.Recent).document(recent.objectId).updateData(values) { (error) in
            
            
            print("error update recent", error)
        }
    }

    func resetRecendCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in

            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                if let recentData = snapshot.documents.first?.data() {
                    
                    let recent = RecentChat(recentData)
                    
                    self.clearUnreadCounter(recent: recent)
                }
            }
        }
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        
        let values = [kUNREADCOUNTER : 0] as [String : Any]
        
        FirebaseReference(.Recent).document(recent.objectId).updateData(values) { (error) in
            
            print("reset recent counter")
        }
    }
    
    
}
