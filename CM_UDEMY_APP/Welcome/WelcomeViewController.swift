//
//  WelcomeViewController.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 25/11/20.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var senhaTextField: UITextField!
    @IBOutlet var backGroundImageView: UIImageView!
    

    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark

        setupBackgroundTouch()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - IBActions
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {

        if emailTextField.text != "" {
            //--reset senha
            
            FUser.resetPassword(email: emailTextField.text!) { (error) in
                if error != nil{
                    ProgressHUD.show(error!.localizedDescription)
                } else {
                    ProgressHUD.showSuccess("Por favor, verifique seu e-mail")
                }
            }
            
        } else {
            //--show erro
            ProgressHUD.showError("Insira seu e-mail, por favor!")
        }
        
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text != "" && senhaTextField.text != "" {
            //--login
            
            ProgressHUD.show()
            
            FUser.loginUserWith(email: emailTextField.text!, password: senhaTextField.text!) { (error, isEmailVerified) in

                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                } else if isEmailVerified {
                    ProgressHUD.dismiss()
                    self.goToApp()
                } else {
                    ProgressHUD.showError("Por favor confirme seu email, acesse sua conta e faça esse processo")
                }
                
            }
            
        } else {
            //--show erro
            ProgressHUD.showError("Insira seu e-mail e sua senha, por favor!")
        }
        
    }
    
    //MARK: - setup
    private func setupBackgroundTouch () {
        backGroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        
        backGroundImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundTap () {
        print("tap")
        
        dismissKeyboard()
        
    }
    
    //MARK: - helpers
    private func dismissKeyboard(){
        
        self.view.endEditing(false)        
        
    }
    

    private func goToApp() {

        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController

        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
}
