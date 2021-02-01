//
//  MatchObject.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import Foundation

struct MatchObject {
    
    let id: String
    let memberIds: [String]
    let date: Date

    var dictionary: [String : Any] {
        return [KOBJECTID : id, kMEMBERIDS : memberIds, kDATE : date]
    }
    
    func saveToFireStore() {
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }
}

