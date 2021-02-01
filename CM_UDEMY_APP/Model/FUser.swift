//
//  FUser.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 26/11/20.
//

import Foundation
import Firebase
import UIKit

class FUser: Equatable {
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }

    let objectId: String
    var email: String
    var username: String
    var dateOfBirth: Date
    var isMale: Bool
    var avatar: UIImage?
    var profession: String
    var jobTitle: String
    var about: String
    var city: String
    var country: String
    var height: Double
    var lookingFor: String
    var avatarLink: String
    
    var likedIdArray: [String]?
    var imageLinks: [String]?
    let registeredDate = Date()
    var pushId: String?
    
    var age: Int
    
    var userDict: NSDictionary {
        
        return NSDictionary(objects: [
                                    self.objectId,
                                    self.email,
                                    self.username,
                                    self.dateOfBirth,
                                    self.isMale,
                                    self.profession,
                                    self.jobTitle,
                                    self.about,
                                    self.city,
                                    self.country,
                                    self.height,
                                    self.lookingFor,
                                    self.avatarLink,
                                    self.likedIdArray ?? [],
                                    self.imageLinks ?? [],
                                    self.registeredDate,
                                    self.pushId ?? "",
                                    self.age
            ],
        
        forKeys: [ KOBJECTID as NSCopying,
                   KEMAIL as NSCopying,
                   KUSERNAME as NSCopying,
                   KDATEOFBIRTH as NSCopying,
                   KISMALE as NSCopying,
                   KPROFESSION as NSCopying,
                   KJOBTITLE as NSCopying,
                   KABOUT as NSCopying,
                   KCITY as NSCopying,
                   KCOUNTRY as NSCopying,
                   KHEIGHT as NSCopying,
                   KLOOKINGFOR as NSCopying,
                   KAVATARLINK as NSCopying,
                   KLIKEDIDARRAY as NSCopying,
                   KIMAGELINKS as NSCopying,
                   KREGISTEREDDATE as NSCopying,
                   KPUSHID as NSCopying,
                   kAGE as NSCopying
        ])
    }
    
    //MARK: - inits
    init(_objectId: String, _email: String, _username: String, _city: String , _dateOfBirth: Date, _isMale: Bool, _avatarLink: String = "") {
        objectId = _objectId
        email = _email
        username = _username
        dateOfBirth = _dateOfBirth
        isMale = _isMale
        profession = ""
        jobTitle = ""
        about = ""
        city = _city
        country = ""
        height = 0.0
        lookingFor = ""
        avatarLink = _avatarLink
        likedIdArray = []
        imageLinks = []
        age = abs(dateOfBirth.interval(ofComponent: .year, fromDate: Date()))
    }
    
    init(_dicitionary: NSDictionary ) {
        objectId = _dicitionary[KOBJECTID] as? String ?? ""
        email = _dicitionary[KEMAIL] as? String ?? ""
        username = _dicitionary[KUSERNAME] as? String ?? ""
        isMale = _dicitionary[KISMALE] as? Bool ?? true
        profession = _dicitionary[KPROFESSION] as? String ?? ""
        jobTitle = _dicitionary[KJOBTITLE] as? String ?? ""
        about = _dicitionary[KABOUT] as? String ?? ""
        city = _dicitionary[KCITY] as? String ?? ""
        country = _dicitionary[KCOUNTRY] as? String ?? ""
        height = _dicitionary[KHEIGHT] as? Double ?? 0.0
        lookingFor = _dicitionary[KLOOKINGFOR] as? String ?? ""
        avatarLink = _dicitionary[KAVATARLINK] as? String ?? ""
        likedIdArray = _dicitionary[KLIKEDIDARRAY] as? [String]
        imageLinks = _dicitionary[KIMAGELINKS] as? [String]
        pushId = _dicitionary[KPUSHID] as? String ?? ""
        
        age = _dicitionary[kAGE] as? Int ?? 18

        if let date = _dicitionary[KDATEOFBIRTH] as? Timestamp {
            dateOfBirth = date.dateValue()
        } else {
            dateOfBirth = _dicitionary[KDATEOFBIRTH] as? Date ?? Date()
        }

        let placeHolder = isMale ? "mPlaceholder" : "fPlaceholder"
        
        avatar = UIImage(contentsOfFile: fileDocumentsDirectory(filename: self.objectId)) ?? UIImage(named: placeHolder)
    }
    
    func getUserAvatarFromFirestore(completion: @escaping(_ didSet: Bool) -> Void){
        
        FileStorage.downloadImage(imageURL: self.avatarLink) { (avatarImage) in
            let placeholder = self.isMale ? "mPlaceholder" : "fPlaceholder"
            self.avatar = avatarImage ?? UIImage(named: placeholder)
            
            completion(true)
        }
        
    }
    
    //MARK: - login
    class func loginUserWith(email: String, password: String, completion : @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil {
                if authDataResult!.user.isEmailVerified{

                    //check if the user exist on database
                    FireBaseListener.shared.downloadCurrentUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    
                    completion(error, true)
                } else {
                    print("email not verified")
                    completion(error, false)
                }
                
                
            } else {
                completion(error, false)
            }
        }
        
        //FirebaseReference(.User)
    }

    //MARK: returning current user
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
        
    class func currentUser() -> FUser? {
        if Auth.auth().currentUser != nil{
            if let userDictionary = userDefaults.object(forKey: KCURRENTUSER) {
                return FUser(_dicitionary: userDictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    
    

    //MARK: - register
    class func registerUserWith (email: String, password: String, userName: String, city: String, isMale: Bool, dateOfBirth: Date, completion: @escaping(_ error: Error?) -> Void) {
    
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            
            completion(error)

            if error == nil {
                
                authData!.user.sendEmailVerification { (error) in
                    print("auth email verification sent", error?.localizedDescription)
                }
                
                
                if authData?.user != nil {
                    
                    let user = FUser(_objectId: authData!.user.uid, _email: email, _username: userName, _city: city, _dateOfBirth: dateOfBirth, _isMale: isMale)
                    
                    user.saveUserLocally()
                }
            }
        }
    }

    //MARK: edit user profile
    func updateUserEmail(newEmail: String, completion: @escaping(_ error: Error?) -> Void){
            
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            
            FUser.resendVerificationEmail(email: newEmail) { (error) in
                
            }
            
            completion(error)
        })
        
    }

    
    //MARK: resend links
    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                
                
                completion(error)
            })
        })
        
    }
    
    class func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void) {
    
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    
    }
    
    //MARK: logoutuser
    class func logoutCurrentUser(completion: @escaping(_ error: Error?) -> Void){
        
        do{
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: KCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError{
            completion(error)
        }
    }

    //MARK: save user func
    func saveUserLocally() {
        
        userDefaults.setValue(self.userDict as! [String: Any], forKey: KCURRENTUSER)
        userDefaults.synchronize()
        
    }
    
    func saveUserToFireStore() {
        
        //FirebaseReference(.User).document(self.objectId).setData(self.userDict as! [String : Any])
        
        FirebaseReference(.User).document(self.objectId).setData(self.userDict as! [String : Any]) { (error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }

    //MARK: update user funcs
    func updateCurrentUserInFireStore(withValues: [String : Any], completion: @escaping(_ error: Error?) -> Void) {
        
        if let dictionary = userDefaults.object(forKey: KCURRENTUSER) {
            
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)
            
            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) {
                error in
                
                completion(error)
                
                if error == nil {
                    FUser(_dicitionary: userObject).saveUserLocally()
                }
            }
            
            
        }
    }
}

func createUsers() {
    
    let names = ["Nelza Teste", "Inajara Teste", "Nayane Teste", "Andreia Teste", "Karina Teste", "Céia Teste"]
    var imageIndex = 1
    var userIndex = 1
    var isMale = false
    
    //--data string para date
    let isoDate = "1985-04-14T10:44:00+0000"
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let date = dateFormatter.date(from:isoDate)!
    
    for i in 0..<5 {
        
        let id = UUID().uuidString
        let fileDirectory = "Avatar/_" + "\(id)" + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = FUser(_objectId: id, _email: "user\(userIndex)@mail.com", _username: names[i], _city: "no city", _dateOfBirth: date, _isMale: isMale, _avatarLink: avatarLink ?? "")
            
            isMale.toggle()
            userIndex += 1
            user.saveUserToFireStore()
        }
       
        imageIndex += 1
        if imageIndex == 16 {
            imageIndex = 1
        }
    }
    
}
