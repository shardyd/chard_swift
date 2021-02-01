//
//  RegisterViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 25/11/20.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    //MARCK: - IBOutlets
    @IBOutlet var usuarioTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var cidadeTextField: UITextField!
    @IBOutlet var sexoSegControl: UISegmentedControl!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var senhaTextField: UITextField!
    @IBOutlet var confirmaSenhaTextField: UITextField!
    @IBOutlet var backgroundImageView: UIImageView!
    
    //MARK: - Vars
    var isMale = true

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        
        setupBackgroundTouch ()
        //setupDatePicker ()
    }
    
    //MARK: - IBActions
    @IBAction func registerPressed(_ sender: Any) {
        
        if isTextDataImputed() {
            
            if senhaTextField.text! == confirmaSenhaTextField.text! {
                registerUser()
            } else {
                ProgressHUD.showError("Senhas estão diferentes, ajuste e tente novamente")
            }
            
        } else {
            
            ProgressHUD.showError("Todos os campos são obrigatórios!")
        }
        
    }
    
    @IBAction func sexoSegControlChanged(_ sender: UISegmentedControl) {
        
        isMale = sender.selectedSegmentIndex == 0 ? true : false
        
        print(isMale)
        
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - setup
    /*private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        nascimentoTextField.inputView = datePicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor().primary()
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "cancelar", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "salvar", style: .plain, target: self, action: #selector(doneClicked))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        nascimentoTextField.inputAccessoryView = toolBar
    }*/
    
    private func setupBackgroundTouch () {
        backgroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        
        backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundTap () {
        print("tap")
        
        dismissKeyboard()
        
    }
    
    //MARK: - helpers
    @objc func dismissKeyboard(){
        
        self.view.endEditing(false)
        
    }
    
    @objc func doneClicked() {
        
    }

    
    private func isTextDataImputed() -> Bool {
        
        
        return usuarioTextField.text != "" && emailTextField.text != "" && cidadeTextField.text != "" && senhaTextField.text != "" && confirmaSenhaTextField.text != ""
        
    }
    

    
    /*
    @IBOutlet var sexoSegControl: UISegmentedControl!
    */


    //MARK: - register
    private func registerUser() {
        ProgressHUD.show()
        
        FUser.registerUserWith(email: emailTextField.text!, password: senhaTextField.text!, userName: usuarioTextField.text!, city: cidadeTextField.text!, isMale: isMale, dateOfBirth: datePicker.date, completion: {
            
            error in
                          
            if error ==  nil {
                ProgressHUD.showSuccess("E-mail de verificação enviado, por favor verifique sua conta")
                self.dismiss(animated: true, completion: nil)
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
                               
        })
    }
}
