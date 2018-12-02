//
//  LoginPageViewController.swift
//  iDoIt
//
//  Created by MSadri on 12/2/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var blueBack: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var panelBackGround: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillLayoutSubviews() {
        self.setupLayout()
        self.emailTextField.delegate = self
        self.pTextField.delegate = self
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            print("Loading Action.........")
        }
        // Do not add a line break
        return false
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in

        }) { (_) in
            //
        }
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

        panelBackGround.translatesAutoresizingMaskIntoConstraints = false
        panelBackGround.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -10 * modifyRate).isActive = true
        panelBackGround.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        panelBackGround.leadingAnchor.constraint(equalTo: blueBack.leadingAnchor, constant: 38 * modifyRate).isActive = true
        panelBackGround.heightAnchor.constraint(equalTo: panelBackGround.widthAnchor, multiplier: 84/279).isActive = true
        
        pTextField.translatesAutoresizingMaskIntoConstraints = false
        pTextField.bottomAnchor.constraint(equalTo: panelBackGround.bottomAnchor, constant: -12 * modifyRate).isActive = true
        pTextField.leadingAnchor.constraint(equalTo: panelBackGround.leadingAnchor, constant: 100 * modifyRate).isActive = true
        pTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pTextField.trailingAnchor.constraint(equalTo: panelBackGround.trailingAnchor, constant: -14).isActive = true
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.topAnchor.constraint(equalTo: panelBackGround.topAnchor, constant: 14 * modifyRate).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: panelBackGround.leadingAnchor, constant: 100 * modifyRate).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: panelBackGround.trailingAnchor, constant: -14).isActive = true
        

        
    
        
        
    }
    


}
