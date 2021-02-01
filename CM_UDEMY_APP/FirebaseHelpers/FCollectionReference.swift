//
//  FCollectionReference.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 26/11/20.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case like
    case Match
    case Recent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
