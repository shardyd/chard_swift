//
//  ProfileTableViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 30/11/20.
//

import UIKit
import Gallery
import ProgressHUD

class ProfileTableViewController: UITableViewController {

    //MARK: - iboutles
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var profileCellBackgroundView: UIView!
    @IBOutlet var nameAgeLabel: UILabel!
    @IBOutlet var cityCountryLabel: UILabel!
    @IBOutlet var aboutMeTextView: UITextView!
    @IBOutlet var jobTextField: UITextField!
    @IBOutlet var professionTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var lookingForTextField: UITextField!
    
    @IBOutlet var ageFromLabel: UILabel!
    @IBOutlet var ageToLabel: UILabel!
    
    @IBOutlet var ageFromSliderOutlet: UISlider!
    
    @IBOutlet var ageToSliderOutlet: UISlider!
    
    
    @IBOutlet var aboutMeView: UIView!

    //MARK: - variable
    var editingMode = false
    var uploadingAvatar = true
    
    var avatarImage: UIImage?
    var gallery: GalleryController!
    
    var alertTextField: UITextField!
    
    var genderPickerView: UIPickerView!
    var genderOptions = ["Male", "Female"]
    
    //MARK: - viewlife cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light

        setupPickerView()
        
        setupBackgrounds()
        setAgeLabels()
        
        if FUser.currentUser() != nil {
            loadUserData()
            updateEditingMode()
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    //MARK: - ibactions
    @IBAction func settingButtonPressed(_ sender: Any) {
        showEditOptions()
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        showPictureOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editingMode.toggle()
        updateEditingMode()
        
        editingMode ? showKeyboard() : hideKeyboard()
        
        showSaveButton()
    }
    
    @objc func editUserData() {
        
        let user = FUser.currentUser()!
        
        user.about = aboutMeTextView.text
        user.jobTitle = jobTextField.text ?? ""
        user.profession = professionTextField.text ?? ""
        user.isMale = genderTextField.text == "Masculino"
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.lookingFor = lookingForTextField.text ?? ""
        user.height = Double(heightTextField.text ?? "0") ?? 0.0
        
        if avatarImage != nil {
            //--upload a new avatar
            
            uploadAvatar(avatarImage!) { (avatarLink) in
                
                user.avatarLink = avatarLink ?? ""
                user.avatar = self.avatarImage
                
                self.saveUserData(user: user)
                self.loadUserData()

            }

        } else {
            //save user
            saveUserData(user: user)
        }
        
        editingMode = false
        updateEditingMode()
        showSaveButton()
 
    }
    
    private func saveUserData(user: FUser){
        user.saveUserLocally()
        user.saveUserToFireStore()
    }
    
    
    @IBAction func ageFromSliderValueChanged(_ sender: UISlider) {

        self.ageFromLabel.text = "Idade de " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }
    
    @IBAction func ageToSliderValueChanged(_ sender: UISlider) {

        self.ageToLabel.text = "Idade até " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }
    
    private func saveAgeSettings() {
        
        userDefaults.setValue(ageFromSliderOutlet.value, forKey: kAGEFROM)
        userDefaults.setValue(ageToSliderOutlet.value, forKey: kAGETO)
        userDefaults.synchronize()

    }
    
    private func setAgeLabels() {
        
        let ageFrom  = userDefaults.object(forKey: kAGEFROM) as? Float ?? 20.0
        let ageTo  = userDefaults.object(forKey: kAGETO) as? Float ?? 50.0
        
        ageFromSliderOutlet.value = ageFrom
        ageToSliderOutlet.value = ageTo
        
        self.ageFromLabel.text = "Idade de " + String(format: "%.0f", ageFrom)
        self.ageToLabel.text = "Idade até " + String(format: "%.0f", ageTo)
    }
    
    //MARK: setup
    
    private func setupBackgrounds() {
        profileCellBackgroundView.clipsToBounds = true
        profileCellBackgroundView.layer.cornerRadius = 100
        profileCellBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        aboutMeView.layer.cornerRadius = 10
        
    }
    
    private func showSaveButton(){
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editUserData))
        
        navigationItem.rightBarButtonItem = editingMode ? saveButton : nil
    }

    private func setupPickerView() {
        genderPickerView = UIPickerView()
        genderPickerView.delegate = self

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor().primary()
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "salvar", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        doneButton.tintColor = .black
        
        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        lookingForTextField.inputAccessoryView = toolBar
        lookingForTextField.inputView = genderPickerView
    }
 
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: load user data
    private func loadUserData() {
        let currentUser = FUser.currentUser()!
        
        FileStorage.downloadImage(imageURL: currentUser.avatarLink) {
            (image) in
            
        }
        
        nameAgeLabel.text = currentUser.username + ", \(abs(currentUser.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        cityCountryLabel.text = currentUser.country + ", " + currentUser.city
        aboutMeTextView.text = currentUser.about != "" ?  currentUser.about : "Um pouco mais sobre mim..."
        
        jobTextField.text = currentUser.jobTitle
        professionTextField.text = currentUser.profession
        genderTextField.text = currentUser.isMale ? "Masculino" : "Feminino"
        cityTextField.text = currentUser.city
        countryTextField.text = currentUser.country
        heightTextField.text = "\(currentUser.height)"
        lookingForTextField.text = currentUser.lookingFor
        avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        //TODO: set avatar picture
        
        avatarImageView.image = currentUser.avatar?.circleMasked
        
    }

    
    
    //MARK: editing mode
    
    private func updateEditingMode() {
        aboutMeTextView.isUserInteractionEnabled = editingMode
        jobTextField.isUserInteractionEnabled = editingMode
        professionTextField.isUserInteractionEnabled = editingMode
        genderTextField.isUserInteractionEnabled = editingMode
        cityTextField.isUserInteractionEnabled = editingMode
        countryTextField.isUserInteractionEnabled = editingMode
        heightTextField.isUserInteractionEnabled = editingMode
        lookingForTextField.isUserInteractionEnabled = editingMode
    }
    

    //MARK: helpers
    private func showKeyboard(){
        self.aboutMeTextView.becomeFirstResponder()
    }
    
    private func hideKeyboard(){
        self.view.endEditing(false)
    }

    //MARK: fileStorage
    private func uploadAvatar(_ image: UIImage, completion: @escaping (_ avatarLink: String?) -> Void){
        
        ProgressHUD.show()
        
        let fileDirectory = "Avatar/_" + FUser.currentId() + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in

            ProgressHUD.dismiss()
            //--save file locally
            FileStorage.saveImageLocally(imageData: image.jpegData(compressionQuality: 0.6)! as NSData, fileName: FUser.currentId())
            completion(avatarLink)
        }
        
    }

    
    private func uploadImages(images: [UIImage?]){
        
        ProgressHUD.show()
        
        FileStorage.uploadImages(images) { (imageLinks) in

            ProgressHUD.dismiss()
            
            let currentUser = FUser.currentUser()!
            currentUser.imageLinks = imageLinks
            
            self.saveUserData(user: currentUser)
        }
    }
    
    //MARK: gallery
    private func showGallery(forAvatar: Bool){
        
        uploadingAvatar = forAvatar
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = forAvatar ? 1 : 10
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }

    //MARK: alert controller
    private func showPictureOptions() {
        
        let alertController = UIAlertController(title: "Gravar imagem", message: "Você pode trocar seu avatar ou gravar fotos!", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Trocar avatar", style: .default, handler: { (alert) in
            
            self.showGallery(forAvatar: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Gravar minhas fotos", style: .default, handler: { (alert) in
            
            self.showGallery(forAvatar: false)

        }))
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    private func showEditOptions() {
        
        let alertController = UIAlertController(title: "Editar conta", message: "Você esta prestes a editar informações da sua conta!", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Trocar e-mail", style: .default, handler: { (alert) in
            
            self.showChangeField(value: "Email")
        }))
        
        alertController.addAction(UIAlertAction(title: "Trocar seu nome", style: .default, handler: { (alert) in
            
            self.showChangeField(value: "Nome")
        }))

        alertController.addAction(UIAlertAction(title: "Sair do aplicativo", style: .default, handler: { (alert) in
            
            self.logOutUser()
        }))

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    private func showChangeField(value: String) {
        
        let alertView = UIAlertController(title: "\(value)", message: "Por favor escreva seu \(value)", preferredStyle: .alert)
        
        alertView.addTextField { (textField) in
            self.alertTextField = textField
            //self.alertTextField.placeHolder = "new \(value)"

        }
        
        alertView.addAction(UIAlertAction(title: "update", style: .destructive, handler: { (action) in
            self.updateUserWith(value: value)
        } ))

        alertView.addAction(UIAlertAction(title: "cancelar", style: .cancel, handler:nil))

        self.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: change user info
    private func updateUserWith(value: String){
        
        if alertTextField.text != "" {
            
            //if value == "Email" ? changeEmail() : changeUserName()
            if value == "Email" {
                changeEmail()
            } else {
                changeUserName()
            }
            
        } else {
            ProgressHUD.showError("\(value) esta vazio")
        }
        
    }
    
    private func changeEmail() {
        FUser.currentUser()?.updateUserEmail(newEmail: alertTextField.text!, completion: { (error) in
            
            if error == nil {
                if let currentUser = FUser.currentUser() {
                    currentUser.email = self.alertTextField.text!
                    
                    self.saveUserData(user: currentUser)
                }

                ProgressHUD.showSuccess("Sucesso!")
            } else {
                
                ProgressHUD.showError(error!.localizedDescription)
            }
        })

    }
    
    private func changeUserName (){
        if let currentUser = FUser.currentUser() {
            currentUser.username = alertTextField.text!
            
            saveUserData(user: currentUser)
            loadUserData()
            
        }

        
    }
    
    private func logOutUser() {
        FUser.logoutCurrentUser { (error) in
            
            if error == nil {
                
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
                
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
            
        }
        
    }
    /*override func numberOfSections(in tableView: UITableView) -> Int {

        return 4
    }*/

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}

extension ProfileTableViewController: GalleryControllerDelegate {
    
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]){
        if images.count > 0{
            if uploadingAvatar {
                images.first!.resolve { (icon) in
                    
                    if icon != nil {
                        self.editingMode = true
                        self.showSaveButton()
                        
                        self.avatarImageView.image = icon?.circleMasked
                        self.avatarImage = icon
                    } else {
                        ProgressHUD.showError("Não foi possivel selecinoar a imagem")
                    }
                    
                }
            } else {
                Image.resolve(images: images) { (resolvedImages) in
                    
                    self.uploadImages(images: resolvedImages)
                    
                }
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


extension ProfileTableViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
}

extension ProfileTableViewController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        lookingForTextField.text = genderOptions[row]
    }
}
