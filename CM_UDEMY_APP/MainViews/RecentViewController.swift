//
//  RecentViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit

class RecentViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!

    // MARK: - VARS
    var recentMatches:[FUser] = []
    var recentChats: [RecentChat] = []
    
    // MARK: - lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadMatches()
    }
    
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light

        super.viewDidLoad()
        
        downloadRecents()
    }

    // MARK: - download
    private func downloadMatches(){
        
        FireBaseListener.shared.downloadUserMatches { (matchedUserIds) in
            
            if matchedUserIds.count > 0 {
                
                FireBaseListener.shared.downloadUsersFromFireBase(withIds: matchedUserIds) { (allUsers) in
                    
                    self.recentMatches = allUsers
                
                    DispatchQueue.main.async {
                        
                        //-hide notification spinner
                        self.collectionView.reloadData()
                    }
                }
                
            } else {
                //--note show activity indicator result
                print("no matches")
            }
            
        }
        
    }
    
    private func downloadRecents(){
        FireBaseListener.shared.downloadRecentChatFromFireStore { (allChats) in
            
            self.recentChats = allChats
            
            DispatchQueue.main.async {
                
                //-hide notification spinner
                self.tableView.reloadData()
            }

        }
    }
    
    //MARK: navigation
    private func showUserProfileFor(user: FUser) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (identifier: "ProfileTableView") as! UserProfileTableViewController
        
        profileView.userObject = user
        profileView.isMatchedUser = true
        
        self.navigationController?.pushViewController(profileView, animated: true)
    }
 
    private func goToChat(recent: RecentChat) {
        
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let chatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }
}

extension RecentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        
        cell.generetaCell(recentChat: recentChats[indexPath.row])
        
        return cell
    }
}

extension RecentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        goToChat(recent: recentChats[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = self.recentChats[indexPath.row]
            recent.deleteRecent()
            
            self.recentChats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension RecentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentMatches.count > 0 ? recentMatches.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NewMatchCollectionViewCell
        
        if recentMatches.count > 0 {
            cell.setupCell(avatarLink: recentMatches[indexPath.row].avatarLink)

        } else {
            
            
        }
        
        return cell
    }
}

extension RecentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if recentMatches.count > 0 {
            showUserProfileFor(user: recentMatches[indexPath.row])
        }
    }
}
