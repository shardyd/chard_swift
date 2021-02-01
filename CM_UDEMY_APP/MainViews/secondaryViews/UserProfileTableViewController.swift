//
//  UserProfileTableViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 08/12/20.
//

import UIKit
import SKPhotoBrowser

protocol UserProfileTableViewControllerDelegate{
    func didLikeUser()
    func didDislikeUser()
    
}

class UserProfileTableViewController: UITableViewController {
    // MARK: - iboutlets
    
    @IBOutlet var sectionOneView: UIView!
    @IBOutlet var sectionTwoView: UIView!
    @IBOutlet var sectionThreeView: UIView!
    @IBOutlet var sectionFourView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dislikeButtonOutlet: UIButton!
    @IBOutlet var likeButtonOutlet: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var activiteIndicator: UIActivityIndicatorView!
    
    @IBOutlet var aboutTextView: UITextView!

    @IBOutlet var professionLabel: UILabel!
    @IBOutlet var jobLabel: UILabel!
    
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var lookingForLabel: UILabel!
    
    // MARK: - vars
    var userObject: FUser?
    
    var delegate: UserProfileTableViewControllerDelegate?
    
    var allImages: [UIImage] = []
    
    var isMatchedUser = false

    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 5.0)

    // MARK: - life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pageControl.hidesForSinglePage = true
        
        if userObject != nil {
            updateLikeButtonStatus()
            showUserDetails()
            loadImages()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        //print("show user", userObject?.username)
        
        self.setupBackground()
        hideActivityIndicator()
        
        if isMatchedUser {
            updateUIForMatchedUser()
        }
    }

    // MARK: - ibactions
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
        self.delegate?.didDislikeUser()
        
        if self.navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismissView()
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        self.delegate?.didLikeUser()

        if self.navigationController != nil {
            saveLikeToUser(userId: userObject!.objectId)
            FireBaseListener.shared.saveMatch(userId: userObject!.objectId)
            showMatchView()
        } else {
            dismissView()
        }
    }
    
    @objc func startChatButtonPressed() {
        
        //print("start chat with user")
        goToChat()
    }
    

    //MARK: table view delegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    
    // MARK: - Setup UI
    private func setupBackground() {
        
        sectionOneView.clipsToBounds = true
        sectionOneView.layer.cornerRadius = 30
        sectionOneView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        sectionTwoView.layer.cornerRadius = 10
        sectionThreeView.layer.cornerRadius = 10
        sectionFourView.layer.cornerRadius = 10

    }

    private func updateUIForMatchedUser() {
        
        self.likeButtonOutlet.isHidden = isMatchedUser
        self.dislikeButtonOutlet.isHidden = isMatchedUser
        
        showStartChatButton()
    }
    
    private func showStartChatButton() {
        
        let messageButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(startChatButtonPressed))
        self.navigationItem.rightBarButtonItem = isMatchedUser ? messageButton : nil
    }
    
    //MARK: show user profile
    private func showUserDetails() {
        aboutTextView.text = userObject!.about
        professionLabel.text = userObject!.profession
        jobLabel.text = userObject!.jobTitle
        genderLabel.text = userObject!.isMale ? "Homem" : "Mulher"
        heightLabel.text = String(format: "%.2f", userObject!.height)
        lookingForLabel.text = userObject!.lookingFor
        
    }
    
    // MARK: - activite indicator
    private func showActivityIndicator () {
        self.activiteIndicator.startAnimating()
        self.activiteIndicator.isHidden = false
    }

    private func hideActivityIndicator () {
        self.activiteIndicator.stopAnimating()
        self.activiteIndicator.isHidden = true
    }

    //MARK: load images
    private func loadImages() {
        let placeHolder = userObject!.isMale ? "mPlaceholde" : "fPlaceholde"
        let avatar = userObject!.avatar ?? UIImage(named: placeHolder)
        
        allImages = [avatar!]
        self.setPageControllPages()

        self.collectionView.reloadData()

        if userObject?.imageLinks != nil && userObject!.imageLinks!.count > 0{
            
            showActivityIndicator()
            
            FileStorage.downloadImages(imageURLs: userObject!.imageLinks!) { (returnImages) in
                
                self.allImages += returnImages as! [UIImage]

                DispatchQueue.main.async {
                    self.setPageControllPages()
                    self.hideActivityIndicator()
                    self.collectionView.reloadData()
                }
            }
        } else {
            hideActivityIndicator()
        }
    }
    
    //MARK: page control
    private func setPageControllPages() {
        
        self.pageControl.numberOfPages = self.allImages.count
    }
    
    private func setSelectedPageTo(page: Int){
        
        self.pageControl.currentPage = page
    }
    
    
}


extension UserProfileTableViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allImages.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell

        let countryCity = userObject!.country + ", " + userObject!.city
        let nameAge = userObject!.username + ", " + "\(abs(userObject!.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        
        cell.setupCell(image: allImages[indexPath.row], country: countryCity, nameAge: nameAge, indexPath: indexPath)
        
        return cell
    }
    
    //MARK: skphoto browser
    private func showImages(_ images: [UIImage], startIndex: Int){
        
        var SKImages : [SKPhoto] = []
        
        for image in images{
            let photo = SKPhoto.photoWithImage(image)
            SKImages.append(photo)
        }

        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(startIndex)
        self.present(browser, animated: true, completion: nil)
    }
    
    //MARK: updateUI
    private func updateLikeButtonStatus() {
        likeButtonOutlet.isEnabled = !FUser.currentUser()!.likedIdArray!.contains(userObject!.objectId)

    }
    
    //MARK: helpers
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: navigation
    private func showMatchView() {
        let matchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (identifier: "matchView") as! MatchViewController

        matchView.user = userObject
        matchView.delegate = self

        self.present(matchView, animated: true, completion: nil)
    }
    
    private func goToChat() {
        
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: userObject!)
        
        let chatView = ChatViewController(chatId: chatRoomId, recipientId: userObject!.objectId, recipientName: userObject!.username)
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }
}

extension UserProfileTableViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showImages(allImages, startIndex: indexPath.row)
    }
    
}

extension UserProfileTableViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 453)
        
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setSelectedPageTo(page: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
}

extension UserProfileTableViewController: MatchViewControllerDelegate {
    func didClickSendMessage(to user: FUser) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.goToChat()
        }

        updateLikeButtonStatus()
    }
    
    func didClickKeepSwiping() {
        print("swipe")
        updateLikeButtonStatus()
    }
    
    
    
    
}
