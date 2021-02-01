//
//  ChatViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 16/12/20.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Firebase
import Gallery

class ChatViewController: MessagesViewController {
    
    //MARK: vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    let refreshController = UIRefreshControl()
    
    let currentUser = MKSender(senderId: FUser.currentId(), displayName: FUser.currentUser()!.username)
    
    private var mkmessages: [MKMessage] = []
    
    var loadedMessageDictionaries: [Dictionary<String,Any>] = []

    var gallery: GalleryController!
    
    var initialLoadCopmleted = false
   
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var typingCounter = 0
    
    //MARK: listeners
    var newChatListener: ListenerRegistration?
    var typingListener: TypingListener?
    var updateChatListener: ListenerRegistration?
    
    //MARK: init
    init(chatId: String, recipientId: String, recipientName: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        setChatTitle()
        createTypingObserver()
        
        configureLeftBarButton()
        configureMessageCollectionView()
        configureMessageInputBar()
        
        listenForReadStatusChange()
        
        downloadChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FireBaseListener.shared.resetRecendCounter(chatRoomId: chatId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
        FireBaseListener.shared.resetRecendCounter(chatRoomId: chatId)
    }
    
    //MARK: config
    private func configureLeftBarButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }

    private func configureMessageCollectionView() {

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }

    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
        let button = InputBarButtonItem()
        button.image = UIImage(named: "attach")
        button.setSize(CGSize(width: 30, height: 30), animated: false)
        
        button.onTouchUpInside { (item) in
            //show action sheet
            self.actionAttachMessage()
        }
        
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    private func setChatTitle() {
        
        self.title = recipientName
    }
    
    //MARK: actions
    @objc func backButtonPressed() {
    
        FireBaseListener.shared.resetRecendCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: "Enviar Foto", message: nil, preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Camera", style: .default) { (alert) in
            
            self.showImageGalleryFor(forCamera: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo library", style: .default) { (alert) in
            
            self.showImageGalleryFor(forCamera: false)
        }
        
        let cancel = UIAlertAction(title: "cancelar", style: .cancel, handler: nil)
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func messageSend(text: String?, photo: UIImage?){
        
        Outgoing.send(chatId: chatId, text: text, photo: photo, memberIds: [FUser.currentId(), recipientId])
    }
    
    //MARK: download chat
    
    private func downloadChats() {
        
        FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).limit(to: 15).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                
                //listen for novos chats
                self.initialLoadCopmleted = true
                
                return
            }
            
            self.loadedMessageDictionaries = ((self.dicitionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [Dictionary<String, Any>]
            
            //insert messages to chat room
            self.insertMessages()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            
            self.initialLoadCopmleted = true
            
            self.getOldMessagesInBackground()

            self.listenForNewChats()
        }
    }
    
    private func listenForNewChats() {
        
        newChatListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kDATE, isGreaterThan: lastMessageDate()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        self.insertMessage(change.document.data())
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
                
            }
        })
        
        
    }
    
    private func listenForReadStatusChange() {
        
        updateChatListener = FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                snapshot.documentChanges.forEach { (change) in
                    if change.type == .modified {
                        self.updateMessage(change.document.data())
                    }
                }
            }
        })
    }

    private func updateMessage(_ messageDictionary: Dictionary<String, Any>) {
        
        for index in 0 ..< mkmessages.count {
            let tempMessage = mkmessages[index]
            
            if messageDictionary[KOBJECTID] as! String == tempMessage.messageId {
                
                mkmessages[index].status = messageDictionary[kSTATUS] as? String ?? kSENT
                
                if mkmessages[index].status == kREAD{
                    self.messagesCollectionView.reloadData()
                }
            }
            
        }
    }
    
    //    MARK: insert messages
    private func insertMessages () {
        maxMessageNumber = loadedMessageDictionaries.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            
            let messageDictionary = loadedMessageDictionaries[i]
            insertMessage(messageDictionary)
            displayingMessageCount += 1
        }
    }

    private func insertMessage(_ messageDictionary: Dictionary<String, Any>) {
        
        markMessageAsRead(messageDictionary)
        
        let incoming = IncomingMessage(collectionView_: self)
        
        //self.mkmessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
        
        self.mkmessages.append(incoming.createMessage(messageDictionary: messageDictionary)!)
    }

    private func insertOldMessage(_ messageDictionary: Dictionary<String, Any>) {
        
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
    }

    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOld {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            let messageDicitionary = loadedMessageDictionaries[i]
            insertOldMessage(messageDicitionary)
            displayingMessageCount += 1
        }
        
        loadOld = true
    }
    
    private func markMessageAsRead (_ messageDictionary: Dictionary<String, Any>) {
        
        if messageDictionary[kSENDERID] as! String != FUser.currentId() {
            
            Outgoing.updateMessage(withId: messageDictionary[KOBJECTID] as! String, chatRoomId: chatId, memberIds: [FUser.currentId(), recipientId])
        }
    }

    private func removeListeners() {
        
        if newChatListener != nil {
            newChatListener!.remove()
        }
        
        if typingListener != nil {
            typingListener!.remove()
        }
        
        if updateChatListener != nil {
            updateChatListener!.remove()
        }
    }
    
    //MARK: uiscrollviewdelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing{
            
            if displayingMessageCount < loadedMessageDictionaries.count {
                
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }
    
    
    private func getOldMessagesInBackground() {
        
        if loadedMessageDictionaries.count > kNUMBEROFMESSAGES {
            
            FirebaseReference(.Messages).document(FUser.currentId()).collection(chatId).whereField(kDATE, isLessThan: firstMessageDate()).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                if !snapshot.isEmpty {
                    
                    self.loadedMessageDictionaries = ((self.dicitionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [Dictionary<String, Any>] + self.loadedMessageDictionaries
                    
                    self.messagesCollectionView.reloadData()
                    
                    self.maxMessageNumber = self.loadedMessageDictionaries.count - self.displayingMessageCount - 1
                    self.minMessageNumber = self.maxMessageNumber - kNUMBEROFMESSAGES
                }
            }
        }
    }

    //    MARK: helpers
    private func dicitionaryArrayFromSnapshot(_ snapshots: [DocumentSnapshot]) -> [Dictionary<String, Any>] {
    
        var allMessages: [Dictionary<String, Any>] = []
        
        for snapshot in snapshots {
            
            allMessages.append(snapshot.data()!)
        }
        
        return allMessages
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = (loadedMessageDictionaries.last?[kDATE] as? Timestamp)?.dateValue() ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }

    private func firstMessageDate() -> Date {
        let firstMessageDate = (loadedMessageDictionaries.first?[kDATE] as? Timestamp)?.dateValue() ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: firstMessageDate) ?? firstMessageDate
    }

    //MARK: typing indicator
    private func createTypingObserver() {
        
        TypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            
            
            self.setTypingIndicatorViewHidden(!isTyping, animated: true, whilePerforming: nil) { [weak self] success in
                
                if success, self?.isLastSectinVisible() == true {
                    
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
    }

    private func tapIndicatorUpdate() {
        
        typingCounter += 1
        
        TypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.tapCounterStop()
        }
    }
    
    private func tapCounterStop() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            TypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }

    func isLastSectinVisible() -> Bool {
        
        guard !mkmessages.isEmpty else {
            return false
        }
        
        let lastIndexPath = IndexPath(item: 0, section: mkmessages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    //MARK: gallery
    private func showImageGalleryFor(forCamera: Bool) {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = forCamera ? [.cameraTab] : [.imageTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return mkmessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkmessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        
        if indexPath.section % 3 == 0 {
            
            let showLoadMore = (indexPath.section == 0) && loadedMessageDictionaries.count > displayingMessageCount
            
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.boldSystemFont(ofSize: 15) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font,.foregroundColor: color])
        }
        
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isFromCurrentSender(message: message) {
            let message = mkmessages[indexPath.section]
            let status = indexPath.section == mkmessages.count - 1 ? message.status : ""
            
            return NSAttributedString(string: status, attributes: [.font: UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
}

extension ChatViewController: MessagesLayoutDelegate{
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            
            if (indexPath.section == 0) && loadedMessageDictionaries.count > displayingMessageCount {
                return 40
            }
            
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }

    func  configAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView ) {
        
        avatarView.set(avatar: Avatar(initials: mkmessages[indexPath.section].senderInitials))
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        
        switch detector {
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutgoing : MessageDefaults.bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(tail, .curved)
    }
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        print("tap on image message")
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        if text != "" {
            self.tapIndicatorUpdate()
            
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components{
            
            if let text = component as? String{
                //send message func
                messageSend(text: text, photo: nil)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}

extension ChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {

        if images.count > 0 {
            images.first!.resolve { (image) in
                print("we have message with image")
                self.messageSend(text: nil, photo: image)
            }
        }

        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
