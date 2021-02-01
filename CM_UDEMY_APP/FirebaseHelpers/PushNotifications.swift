//
//  PushNotifications.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 20/01/21.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init () {
        
    }
    
    
    func sendPushNotificationTo(userId: [String], body: String) {
        
        FireBaseListener.shared.downloadUsersFromFireBase(withIds: userId) { (users) in
            for user in users {
                
                if let pushId = user.pushId {
                    self.sendMessageToUser(to: pushId, title: FUser.currentUser()!.username, body: body)
                }
            }
        }
    }

    private func sendMessageToUser(to token: String, title: String, body: String) {
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        let paramString :[String : Any] = ["to" : token,
                                           "notification" : [
                                            "title" : title,
                                            "body" : body,
                                            "budge" : "1",
                                            "sound" : "default"
                                           ]
        ]
        
        
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "post"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(KSERVERKEY)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
        }

        task.resume()
    }
    
}
