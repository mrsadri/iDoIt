//
//  RegisterPageViewController.swift
//  iDoIt
//
//  Created by MSadri on 12/3/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController, UITextFieldDelegate, AccessToLoginRegistrationPage{
    
    
    @IBOutlet weak var blueBack: UIImageView!
    @IBOutlet weak var registerPanel: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var stackViewM: UIStackView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedObject.isItFirstTimeToSetWholeData = true
        DataManager.sharedObject.delegateToAccessLoginPage = self
        self.setupLayout()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.pTextField.delegate = self
       // --
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerButton.isEnabled = true
    }
    
    func changeAvabilityOfButton(to flag: Bool){
        registerButton.isEnabled = flag
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
     registerAction()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            print("Register Action.........")
            registerAction()
        }
        // Do not add a line break
        return false
    }
    
    func registerAction() {
        if registerButton.isEnabled {
            let name : String = firstNameTextField.text ?? "No Name"
            let lastName : String = lastNameTextField.text ?? "No Last Name"
            let email : String = emailTextField.text ?? "No Email"
            let thisPass : String = pTextField.text ?? "Ali123"
            DataManager.sharedObject.register(firstName: name, lastName: lastName, password: thisPass, email: email)
            registerButton.isEnabled = false
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
        blueBack.heightAnchor.constraint(equalTo: blueBack.widthAnchor, multiplier: 394/367 ).isActive = true
        
        let modifyRate = self.blueBack.bounds.width / 367
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.bottomAnchor.constraint(equalTo: blueBack.bottomAnchor, constant: -30 * modifyRate).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: blueBack.leadingAnchor, constant: 35 * modifyRate).isActive = true
        registerButton.heightAnchor.constraint(equalTo: registerButton.widthAnchor, multiplier: 53/286 ).isActive = true

        registerPanel.translatesAutoresizingMaskIntoConstraints = false
        registerPanel.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -10 * modifyRate).isActive = true
        registerPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        registerPanel.leadingAnchor.constraint(equalTo: blueBack.leadingAnchor, constant: 38 * modifyRate).isActive = true
        registerPanel.heightAnchor.constraint(equalTo: registerPanel.widthAnchor, multiplier: 160/279).isActive = true
        
        stackViewM.translatesAutoresizingMaskIntoConstraints = false
        stackViewM.bottomAnchor.constraint(equalTo: registerPanel.bottomAnchor, constant: -14).isActive = true
        stackViewM.leadingAnchor.constraint(equalTo: registerPanel.centerXAnchor, constant: -30).isActive = true
        stackViewM.centerYAnchor.constraint(equalTo: registerPanel.centerYAnchor).isActive = true
        stackViewM.trailingAnchor.constraint(equalTo: registerPanel.trailingAnchor, constant: -14).isActive = true
    }
    
}
