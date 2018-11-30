//
//  LoginRegisterViewController.swift
//  iDoIt
//
//  Created by MSadri on 11/28/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

protocol AccessToLoginRegistrationPage {
    func loadTheApplication()
}
class LoginRegisterViewController: UIViewController , AccessToLoginRegistrationPage {

    
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var kastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TalkToServer.sharedObject.isItFirstTimeToSetWholeData = true
        TalkToServer.sharedObject.delegateToAccessLoginPage = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentControll(_ sender: Any) {
        if segmentControll.selectedSegmentIndex == 1 {
            nameLabel.isHidden = true
            nameTextField.isHidden = true
            kastNameLabel.isHidden = true
            lastNameTextField.isHidden = true
        } else {
            nameLabel.isHidden = false
            nameTextField.isHidden = false
            kastNameLabel.isHidden = false
            lastNameTextField.isHidden = false
        }
    }
    
    @IBAction func loginRegisterButtonAction(_ sender: UIButton) {
        if segmentControll.selectedSegmentIndex == 0 {
            //Register
            let name : String = nameTextField.text ?? "No Name"
            let lastName : String = lastNameTextField.text ?? "No Last Name"
            let email : String = emailTextField.text ?? "No Email"
            let thisPass : String = passWordTextField.text ?? "Ali123"
            TalkToServer.sharedObject.register(firstName: name, lastName: lastName, password: thisPass, email: email)
        } else {
            //Login
            let email : String = emailTextField.text ?? "No Email"
            let thisPass : String = passWordTextField.text ?? "Ali123"
            TalkToServer.sharedObject.login(email: email, password: thisPass)
        }
    }
    
    func loadTheApplication(){
        print(wholeDate)
        print("try to load the application")
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
        let mainPage = storyboard?.instantiateViewController(withIdentifier: "mainPage")
        //swipingController.view.backgroundColor = .black
        self.present(mainPage!, animated: true) {
            //nothing
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
