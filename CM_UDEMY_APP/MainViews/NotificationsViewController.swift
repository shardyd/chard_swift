//
//  NotificationsViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 15/12/20.
//

import UIKit
import ProgressHUD

class NotificationsViewController: UIViewController {
    //MARK: -IBOutlets
    @IBOutlet var tableView: UITableView!

    //MARK: -VARS
    var allLikes: [LikeObject] = []
    var allUsers: [FUser] = []
    
    //MARK: view life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadLikes()
    }
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light

        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    //MARK: downloadLikes
    private func downloadLikes() {
        
        ProgressHUD.show()
        
        FireBaseListener.shared.downloadUserLikes { (allUserIds) in
            
            if allUserIds.count > 0 {
                
                FireBaseListener.shared.downloadUsersFromFireBase(withIds: allUserIds) { (allUsers) in
                    ProgressHUD.dismiss()
                    
                    self.allUsers = allUsers
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            } else {
                ProgressHUD.dismiss()
            }
        }
    }
    
    //MARK: navigation
    private func showUserProfileFor(user: FUser) {
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (identifier: "ProfileTableView") as! UserProfileTableViewController
        
        profileView.userObject = user
        
        self.navigationController?.pushViewController(profileView, animated: true)
        
        //self.present(profileView, animated: true, completion: nil)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeTableViewCell
        
        cell.setupCell(user: allUsers[indexPath.row])
        
        return cell
    }
    
}

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        showUserProfileFor(user: allUsers[indexPath.row])
    }
}
