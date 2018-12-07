//
//  LoginPageViewController.swift
//  iDoIt
//
//  Created by MSadri on 12/2/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

@objc protocol AccessToLoginRegistrationPage {
    func loadTheApplication()
    @objc optional func changeAvabilityOfButton(to flag:Bool)
}

class LoginPageViewController: UIViewController, UITextFieldDelegate, AccessToLoginRegistrationPage {

    @IBOutlet weak var blueBack: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginPanel: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedObject.isItFirstTimeToSetWholeData = true
        DataManager.sharedObject.delegateToAccessLoginPage = self
        self.setupLayout()
        self.emailTextField.delegate = self
        self.pTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginButton.isEnabled = true
    }
    
    func changeAvabilityOfButton(to flag: Bool){
        loginButton.isEnabled = flag
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        loginAction()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            print("Loading Action.........")
            loginAction()
        }
        // Do not add a line break
        return false
        
    }
    
    func loginAction(){
        if loginButton.isEnabled {
            let email : String = emailTextField.text ?? "No Email"
            let thisPass : String = pTextField.text ?? "Ali123"
            DataManager.sharedObject.login(email: email, password: thisPass)
            loginButton.isEnabled = false
        }
    }
    
    func loadTheApplication(){
        let mainPage = storyboard?.instantiateViewController(withIdentifier: "mainPage")
        self.present(mainPage!, animated: true, completion: nil)
    }
    
    func setupLayout() {
        blueBack.translatesAutoresizingMaskIntoConstraints = false
        blueBack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        blueBack.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor , constant: 5).isActive = true
        blueBack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        if Int(view.bounds.size.width ) - 10 < 367 {
            blueBack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor , constant: 5).isActive = true
        } else {
            let i = 0.5 * (self.view.bounds.width - 367)
            blueBack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor , constant: i).isActive = true
        }
        blueBack.heightAnchor.constraint(equalTo: blueBack.widthAnchor, multiplier: 318/367 ).isActive = true
        
        let modifyRate = self.blueBack.bounds.width / 367
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.bottomAnchor.constraint(equalTo: blueBack.bottomAnchor, constant: -30 * modifyRate).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: blueBack.leadingAnchor, constant: 35 * modifyRate).isActive = true
        loginButton.heightAnchor.constraint(equalTo: loginButton.widthAnchor, multiplier: 53/286 ).isActive = true
        
        loginPanel.translatesAutoresizingMaskIntoConstraints = false
        loginPanel.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -10 * modifyRate).isActive = true
        loginPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginPanel.leadingAnchor.constraint(equalTo: blueBack.leadingAnchor, constant: 38 * modifyRate).isActive = true
        loginPanel.heightAnchor.constraint(equalTo: loginPanel.widthAnchor, multiplier: 84/279).isActive = true
        
        pTextField.translatesAutoresizingMaskIntoConstraints = false
        pTextField.bottomAnchor.constraint(equalTo: loginPanel.bottomAnchor, constant: -14).isActive = true
        pTextField.leadingAnchor.constraint(equalTo: loginPanel.centerXAnchor, constant: -30).isActive = true
        pTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pTextField.trailingAnchor.constraint(equalTo: loginPanel.trailingAnchor, constant: -14).isActive = true
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.topAnchor.constraint(equalTo: loginPanel.topAnchor, constant: 14 ).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: loginPanel.centerXAnchor, constant: -30).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: loginPanel.trailingAnchor, constant: -14).isActive = true
        
    }
    
}
