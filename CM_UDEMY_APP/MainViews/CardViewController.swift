//
//  CardViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 03/12/20.
//

import UIKit
import Shuffle_iOS
import Firebase
import ProgressHUD

class CardViewController: UIViewController {

    
    @IBOutlet var emptyDataView: EmptyDataView!
    
    //MARK: vars
    private let cardStack = SwipeCardStack()
    private var initialCardModels: [UserCardModel] = []
    private var secondCardModel: [UserCardModel] = []
    private var userObjects: [FUser] = []
    
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false

    var numberOfCardsAdded = 0
    var initialLoadNumber = 6
        
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showEmptyDataView(loading: true)
        emptyDataView.delegate = self

        overrideUserInterfaceStyle = .light

        downloadInitialUsers()
        
        //-- tirar quando for recriar
//        let user = FUser.currentUser()!
//        user.likedIdArray = []
//        user.saveUserLocally()
//        user.saveUserToFireStore()
        
        
        //-cria mais usuarios modelo
        //createUsers()
        
        //--mostra o proprio usuario
        /*let user = FUser.currentUser()!
        
        let cardModel = UserCardModel(id: user.objectId,
                                      name: user.username,
                                      age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                      occupation: user.profession,
                                      image: user.avatar)
        
        initialCardModels.append(cardModel)
        layoutCardsStackView()*/
    }
    
    private func showEmptyDataView(loading: Bool) {
        
        emptyDataView.isHidden = false
        emptyDataView.reloadButton.isEnabled = true
        
        let imageName = loading ? "searchingBackground" : "seenAllBackground"
        let title = loading ? "Procurando por usuários..." : "Você já passou por todos"
        let subTitle = loading ? "Por favor espere..." : "Por favor tente novamente..."

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.view.bringSubviewToFront(self.emptyDataView)
        }
        
        emptyDataView.imageView.image = UIImage(named: imageName)
        emptyDataView.titleLabel.text = title
        emptyDataView.subtitleLabel.text = subTitle
        emptyDataView.reloadButton.isHidden = loading
    }
    
    private func hideEmptyDataView() {
        
        emptyDataView.isHidden = true
    }
    
    private func resetLoadCount (){
            
        isInitialLoad = true
        showReserve = false
        lastDocumentSnapshot = nil
        numberOfCardsAdded = 0
    }
    
    
    //MARK: layout cards
    private func layoutCardsStackView(){
        
        hideEmptyDataView()
        
        cardStack.delegate = self
        cardStack.dataSource = self
        
        view.addSubview(cardStack)
        
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
    }

    
    //MARK: download users
    private func downloadInitialUsers() {
        
        ProgressHUD.show()
        
        FireBaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: initialLoadNumber, lastDocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in
            
            if allUsers.count == 0 {
                ProgressHUD.dismiss()
            }
          
            self.lastDocumentSnapshot = snapshot
            self.isInitialLoad = false
            self.initialCardModels = []
            
            self.userObjects = allUsers
            
            for user in allUsers {
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    let cardModel = UserCardModel(id: user.objectId,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                                  image: user.avatar)
                    
                    self.initialCardModels.append(cardModel)

                    self.numberOfCardsAdded += 1
                    
                    if self.numberOfCardsAdded == allUsers.count{
                        
                        print("reload")
                        
                        DispatchQueue.main.async {
                            ProgressHUD.dismiss()
                            
                            self.layoutCardsStackView()
                        }
                    }
                }
            } //--- for loop
            
            print("initial \(allUsers.count) received")
            
            //--get second batch
            self.downloadMoreUsersInBackgroud()
        }
        
    }
    
    
    private func downloadMoreUsersInBackgroud() {
        
        FireBaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: 1000, lastDocumentSnapshot: lastDocumentSnapshot) { (allUsers, snapshot) in
            
            self.lastDocumentSnapshot = snapshot
            self.secondCardModel = []
            
            self.userObjects += allUsers
            
            for user in allUsers {
                
                user.getUserAvatarFromFirestore { (didSet) in
                    
                    
                    let cardModel = UserCardModel(id: user.objectId,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                                  image: user.avatar)
                    
                    self.secondCardModel.append(cardModel)
                    
                }
            }
            
        }
        
    }

    //MARK: navigation
    private func showUserProfileFor(userId: String) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (identifier: "ProfileTableView") as! UserProfileTableViewController
        
        profileView.userObject = self.getUserWithId(userId: userId)
        profileView.delegate = self
        self.present(profileView, animated: true, completion: nil)
    }
    
    private func showMatchView(userId: String) {
        let matchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (identifier: "matchView") as! MatchViewController

        matchView.user = getUserWithId(userId: userId)
        matchView.delegate = self
        self.present(matchView, animated: true, completion: nil)
    }
    
    //MARK: helpers
    private func getUserWithId(userId: String) -> FUser? {
        
        for user in userObjects {
            if user.objectId == userId{
                return user
            }
        }
        
        return nil
    }
    
    private func checkForLikesWith(userId: String) {
        
        print("checking for like")
        
        if !didLikeUserWith(userId: userId) {
            saveLikeToUser(userId: userId)
        }
        
        //fetch likes
        FireBaseListener.shared.checkIfUserLikedUs(userId: userId) { (didLike) in
            
            if didLike {
                
                FireBaseListener.shared.saveMatch(userId: userId)
                self.showMatchView(userId: userId)
            } else {
                
            }
            
        }
    }
    
    private func goToChat(user: FUser){
        
        let chatRoomId = startChat(user1: FUser.currentUser()!, user2: user)
        
        let chatView = ChatViewController(chatId: chatRoomId, recipientId: user.objectId, recipientName: user.username)
     
        chatView.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatView, animated: true)
    }
}

extension CardViewController: SwipeCardStackDelegate, SwipeCardStackDataSource{
    //MARK: datasource
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = UserCard()
        
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]
        
        for direction in card.swipeDirections {
            card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }
        
        card.configure(withModel: showReserve ? secondCardModel[index] : initialCardModels[index])
        
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return showReserve ? secondCardModel.count : initialCardModels.count
    }
    
    //MARK: delegates
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("finish with cards, show reserve is ", showReserve)

        initialCardModels = []
        
        if showReserve {
            secondCardModel = []
        }
        
        showReserve = true
        layoutCardsStackView()
        
        if secondCardModel.isEmpty {
            showEmptyDataView(loading: false)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        //print("swipe to", direction)
        
        if direction == .right {
            let user = getUserWithId(userId: showReserve ? secondCardModel[index].id : initialCardModels[index].id)
            
            checkForLikesWith(userId: user!.objectId)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        
        let userId = showReserve ? secondCardModel[index].id : initialCardModels[index].id
        
        showUserProfileFor(userId: userId)
    }
}

extension CardViewController: UserProfileTableViewControllerDelegate {
    func didLikeUser() {
        cardStack.swipe(.right, animated: true)
    }
    
    func didDislikeUser() {
        cardStack.swipe(.left, animated: true)
    }
}

extension CardViewController: MatchViewControllerDelegate {
    func didClickSendMessage(to user: FUser) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.goToChat(user: user)
        }
    }
    
    func didClickKeepSwiping() {
    }
}

extension CardViewController: EmptyDataViewDelegate {
    func didClickReloadButton() {

        resetLoadCount()
        downloadInitialUsers()
        emptyDataView.reloadButton.isEnabled = false
    }
    
}
