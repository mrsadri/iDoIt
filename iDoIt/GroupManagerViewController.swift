//
//  GroupManagerViewController.swift
//  iDoIt
//
//  Created by MSadri on 11/30/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

class GroupManagerViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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
        print(dataToLoadGroupTable)
        }
        self.groupTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToLoadGroupTable.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataToLoadGroupTable.count {
            let cell = groupTable.dequeueReusableCell(withIdentifier: "lastGroupCell", for: indexPath)
            return cell
        } else {
            let cell = groupTable.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
            cell.textLabel?.text = dataToLoadGroupTable[indexPath.row].groupName
            return cell
        }

    }
    
    //---
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        if editActionsForRowAt.row == dataToLoadGroupTable.count {
            return nil
            
        } else {
            
            let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
                let groupID = self.dataToLoadGroupTable[editActionsForRowAt.row].groupID
                TalkToServer.sharedObject.deleteGroup(group_id: groupID)
            }
            remove.backgroundColor = .red
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                self.editGroup(indexPath: editActionsForRowAt)
            }
            edit.backgroundColor = .lightGray
            
            return [edit, remove]
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
                TalkToServer.sharedObject.deleteGroup(group_id: groupID)
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
            TalkToServer.sharedObject.updateGroup(groupName: newGroupTitle.text!, group_id: groupID)
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
            TalkToServer.sharedObject.createGroup(groupName: newGroupName.text!)
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
        groupTable.delegate = self
        groupTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.reloadTableData()
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: false) {
            //nothing
        }
    }
    
}
