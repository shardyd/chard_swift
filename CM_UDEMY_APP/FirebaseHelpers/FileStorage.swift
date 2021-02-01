//
//  FileStorage.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 01/12/20.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: KFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 0.6) //60 por cento do original
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading image", error!.localizedDescription)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                
                guard let downloadUrl = url else {
                    completion("")
                    
                    return
                }
                
                print("we have upload image to")
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
        
    }
    
    class func uploadImages(_ images: [UIImage?], completion: @escaping (_ imageLinks: [String]) -> Void) {
        
        var uploadImagesCount = 0
        var imageLinkArray : [String] = []
        var nameSuffix = 0
        
        for image in images {
            //nameSuffix++;
            
            let fileDirectory = "UserImages/" + FUser.currentId() + "/" + "\(nameSuffix)" + ".jpg"
            
            uploadImage(image!, directory: fileDirectory) { (imageLink) in
                
                if imageLink != nil {
                    
                    imageLinkArray.append(imageLink!)
                    uploadImagesCount += 1
                    
                    if uploadImagesCount == images.count {
                        completion(imageLinkArray)
                    }
                }
            }
            
            nameSuffix += 1
        }
    }
    
    class func downloadImage(imageURL: String, completion: @escaping (_ image: UIImage?)-> Void){
        
        let imageFileName = imageURL.components(separatedBy: "_").last!
        let imageFileName2 = imageFileName.components(separatedBy: "?").first!
        let imageFileName3 = imageFileName2.components(separatedBy: ".").first!

        if fileExistsAt(path: imageFileName3) {
            
            if let contensOfFile = UIImage(contentsOfFile: fileDocumentsDirectory(filename: imageFileName3)){
                completion(contensOfFile)
            } else {
                print("nao foi possivel gerar")
                completion(nil)
            }
        } else {
            //download
            if imageURL != "" {
                
                let documentURL = URL(string: imageURL)
                
                let downloadQueue = DispatchQueue(label: "downloadQueue")

                downloadQueue.async {
                    let data = NSData(contentsOf: documentURL!)
                    
                    if data != nil {
                        
                        let imageToReturn = UIImage(data: data! as Data)
                        
                        FileStorage.saveImageLocally(imageData: data!, fileName: imageFileName3)
                        
                        completion(imageToReturn)
                        
                    } else {
                        print("no imagem in database")
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    class func downloadImages(imageURLs: [String], completion: @escaping (_ images: [UIImage?])-> Void){

        var imageArrays: [UIImage] = []
        var downloadCounter = 0
        
        for link in imageURLs {
            let url = URL(string: link)
            //let url = URL(fileURLWithPath: link)
            
            let downloadQueue = DispatchQueue(label: "downloadQueue")

            downloadQueue.async {
                downloadCounter += 1
                let data = NSData(contentsOf: url! as URL)
                
                if data != nil {
                    imageArrays.append(UIImage(data: data! as Data)!)
                    
                    if downloadCounter == imageArrays.count {
                        completion(imageArrays)
                    }
                } else {
                    print("no imagem in database")
                    completion(imageArrays)
                }
            }
        }
    }
    
    class func saveImageLocally(imageData: NSData, fileName: String) {
        
        var docURL = getDocumentURL()
        docURL = docURL.appendingPathComponent(fileName, isDirectory: false)
        
        imageData.write(to: docURL, atomically: true)
    }
    
}

func getDocumentURL() -> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentsURL!
}
    
func fileDocumentsDirectory(filename: String) -> String{
    let fileURL = getDocumentURL().appendingPathComponent(filename)
    
    return fileURL.path
}

func fileExistsAt(path: String) -> Bool{
    
    /*var doesExist = false
    
    let filePath = fileDocumentsDirectory(filename: path)
    
    if FileManager.default.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist*/
    
    return FileManager.default.fileExists(atPath: fileDocumentsDirectory(filename: path))
}
