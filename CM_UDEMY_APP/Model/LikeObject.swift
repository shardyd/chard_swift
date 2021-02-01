//
//  LikeObject.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 09/12/20.
//

import Foundation

struct LikeObject {
    
    let id: String
    let userId: String
    let likedUserId: String
    let date: Date

    var dictionary: [String : Any] {
        return [KOBJECTID : id, kUSERID : userId, kLIKEDUSERID : likedUserId, kDATE : date]
    }
    
    func saveToFireStore() {
        FirebaseReference(.like).document(self.id).setData(self.dictionary)
    }
}

