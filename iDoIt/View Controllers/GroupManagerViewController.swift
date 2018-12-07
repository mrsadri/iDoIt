//
//  GroupManagerViewController.swift
//  iDoIt
//
//  Created by MSadri on 11/30/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

protocol AccessToGroupManagerPage {
    func reloadTableData()
}

class GroupManagerViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, AccessToGroupManagerPage {
    
    @IBOutlet weak var userNameLabel: UILabel!
    func setUserNameLabel(){
        let attributedText = NSMutableAttributedString(string: "\(DataManager.sharedObject.userData.firstName) \(DataManager.sharedObject.userData.lastName)", attributes: [NSAttributedString.Key.font: UIFont.init(name: "ChalkBoard SE", size: 26) ?? UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.white])
        userNameLabel.attributedText = attributedText
    }
    var dataToLoadGroupTable : [(groupName: String, groupID: String)] = [(groupName: "Loading...", groupID: "Loading...")] {
        didSet{
            //nothing
        }
    }
    
    func reloadTableData() {
        dataToLoadGroupTable = []
        if wholeDate.count > 0 {
            for index in 0...wholeDate.count-1 {
                let aGroupData = wholeDate[index].groupData
                dataToLoadGroupTable.append(aGroupData)
            }
        }
        self.groupTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToLoadGroupTable.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataToLoadGroupTable.count {
            let cell = groupTable.dequeueReusableCell(withIdentifier: "lastGroupCell", for: indexPath)
            cell.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
            return cell
        } else {
            let cell = groupTable.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
            let text : String = {
                var thisText : String = ""
                thisText =  String(dataToLoadGroupTable[indexPath.row].groupName).uppercased()
                return thisText
            }()
            let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.init(name: "ChalkBoard SE", size: 15) ?? UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black])
            cell.textLabel?.attributedText = attributedText
            cell.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
            return cell
        }
        
    }
    
    //---
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            let groupID = self.dataToLoadGroupTable[editActionsForRowAt.row].groupID
            DataManager.sharedObject.deleteGroup(group_id: groupID)
        }
        remove.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 0.8)
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editGroup(indexPath: editActionsForRowAt)
        }
        edit.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 1.0)
        
        return [edit, remove]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == dataToLoadGroupTable.count {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == dataToLoadGroupTable.count {
            self.addNewGroup()
        } else {
            let groupTitle : String = dataToLoadGroupTable[indexPath.row].groupName
            let groupID : String = dataToLoadGroupTable[indexPath.row].groupID
            
            let alert = UIAlertController(title: groupTitle, message: nil , preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "Edit Group Name", style: .default) { (action) in
                //---
                self.editGroup(indexPath: indexPath)
                //---
                
            }
            
            let removeAction = UIAlertAction(title: "Remove This Group", style: .destructive) { (action) in
                DataManager.sharedObject.deleteGroup(group_id: groupID)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            alert.addAction(removeAction)
            
            present(alert, animated: true) {
                //do nothing
            }
        }
        self.groupTable.deselectRow(at: indexPath, animated: true)
    }
    
    
    func editGroup(indexPath : IndexPath){
        
        let groupTitle : String = dataToLoadGroupTable[indexPath.row].groupName
        let groupID : String = dataToLoadGroupTable[indexPath.row].groupID
        
        let alertToEditTask = UIAlertController(title: "Edit Group", message: nil , preferredStyle: .alert )
        
        var newGroupTitle       = UITextField()
        
        alertToEditTask.addTextField { (alertTexfieldTitle) in
            alertTexfieldTitle.text = groupTitle
            newGroupTitle = alertTexfieldTitle
        }
        
        let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
            DataManager.sharedObject.updateGroup(groupName: newGroupTitle.text!, group_id: groupID)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) in
        }
        
        alertToEditTask.addAction(addAction)
        alertToEditTask.addAction(cancelAction)
        
        self.present(alertToEditTask, animated: true) {
            //do nothing
        }
    }
    
    func addNewGroup(){
        
        let alertToEditTask = UIAlertController(title: "Add New Group", message: nil , preferredStyle: .alert )
        
        var newGroupName  = UITextField()
        
        alertToEditTask.addTextField { (alertTexfieldTitle) in
            alertTexfieldTitle.placeholder = "Enter Group Name"
            newGroupName = alertTexfieldTitle
        }
        
        let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
            DataManager.sharedObject.createGroup(groupName: newGroupName.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) in
        }
        
        alertToEditTask.addAction(addAction)
        alertToEditTask.addAction(cancelAction)
        
        self.present(alertToEditTask, animated: true) {
            //do nothing
        }
    }
    
    
    @IBOutlet weak var groupTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let mainTablePage = storyboard?.instantiateViewController(withIdentifier: "mainPage") as! ViewController
        //        mainTablePage.delegateOfGroupManagerPage = self
        MainPageViewController.delegateOfGroupManagerPage = self
        print("------ \nDebug:here a delegate is its own value")
        groupTable.delegate = self
        groupTable.dataSource = self
        self.groupTable.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
        setUserNameLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.reloadTableData()
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        DataManager.sharedObject.tokenKeeper = ""
        DataManager.sharedObject.tableSections = []
        DataManager.sharedObject.isItFirstTimeToSetWholeData = true
        
        
        self.dismiss(animated: false) {
            DataManager.sharedObject.delegateToAcessTableView.selfDismiss()
            
        }
        
        
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: false) {
            //nothing
        }
    }
    
}
