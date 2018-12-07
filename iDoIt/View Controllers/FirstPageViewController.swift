//
//  FirstPageViewController.swift
//  iDoIt
//
//  Created by MSadri on 12/2/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController, AccessToLoginRegistrationPage{
    
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    var thisToken : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedObject.isItFirstTimeToSetWholeData = true
        DataManager.sharedObject.delegateToAccessLoginPage = self
        
        

    }
    override func viewDidAppear(_ animated: Bool) {
        
        changeAvabilityOfButton(to: false)
        thisToken = PListControl.sharedObject.userData.token
        DataManager.sharedObject.tokenKeeper = thisToken
        DataManager.sharedObject.userData = (firstName: PListControl.sharedObject.userData.firstName , lastName: PListControl.sharedObject.userData.lastName)
        
        if thisToken == "" {
            changeAvabilityOfButton(to: true)
        }
    }
    @IBAction func loginButton(_ sender: Any) {

    }
    
    func loadTheApplication(){
        let mainPage = storyboard?.instantiateViewController(withIdentifier: "mainPage")
        self.present(mainPage!, animated: true, completion: nil)
    }
    
    func changeAvabilityOfButton(to flag: Bool){
        createAccountBtn.isEnabled = flag
        loginBtn.isEnabled = flag
    }
    
}
