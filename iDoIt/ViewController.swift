//
//  ViewController.swift
//  iDoIt
//
//  Created by MSadri on 11/28/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

protocol AccessToTableView {
    func reloadTableData()
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccessToTableView {
    
    var dataToLoadThisTable :  [TableDataModel] = [ TableDataModel(groupData: (groupName: "Loading...", groupID: "Loading..."), tasksData: [(taskName: "Tasks are loading...", taskID: "1", taskDescription: "Wait..", doneStatus: true )] ) ] {
        didSet{
            print("new Data is set")
        }
    }
    
    func reloadTableData() {
        dataToLoadThisTable = wholeDate
        self.mainTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataToLoadThisTable.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var thisTitle = String()
        thisTitle = dataToLoadThisTable[section].groupData.groupName
        return thisTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var howManyCells = Int()
        howManyCells = dataToLoadThisTable[section].tasksData.count + 1
        return howManyCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if indexPath.row < dataToLoadThisTable[indexPath.section].tasksData.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "thisCell", for: indexPath)
                cell.textLabel?.text  = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskName
        return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "lastCell", for: indexPath)
                return cell
            }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            //remove From server
            TalkToServer.sharedObject.deleteTask(task_id: self.dataToLoadThisTable[editActionsForRowAt.section].tasksData[editActionsForRowAt.row].taskID)
        }
        remove.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editTask(indexPath: editActionsForRowAt)
        }
        edit.backgroundColor = .lightGray
        
        let done = UITableViewRowAction(style: .normal, title: "Done") { action, index in
            print("Done button tapped")
        }
        done.backgroundColor = .green
        
        return [done, edit, remove]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == dataToLoadThisTable[indexPath.section].tasksData.count {
            self.addNewTask(indexPath: indexPath)
        } else {
        
        let taskTitle       : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskName
        let taskDescription : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskDescription
        
        let alert = UIAlertController(title: taskTitle, message: taskDescription , preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "Edit Task", style: .default) { (action) in
            print("Edit Task")
            //---
            self.editTask(indexPath: indexPath)
            //---
            
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
            let taskId = self.dataToLoadThisTable[indexPath.section].tasksData[indexPath.item].taskID
            TalkToServer.sharedObject.deleteTask(task_id: taskId)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        
        present(alert, animated: true) {
            //do nothing
        }
        }
        self.mainTable.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBOutlet weak var mainTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainTable.delegate = self
        mainTable.dataSource = self
        TalkToServer.sharedObject.delegateToAcessTableView = self
        self.dataToLoadThisTable = wholeDate
    }
    
    
    
    func editTask(indexPath : IndexPath){
        let taskTitle       : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskName
        let taskDescription : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskDescription
        let taskID          : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskID
        let groupID         : String = dataToLoadThisTable[indexPath.section].groupData.groupID
        
        let alertToEditTask = UIAlertController(title: "Edit Task", message: nil , preferredStyle: .alert )
        
        var newTaskTitle       = UITextField()
        var newTaskDescription = UITextField()
        
        alertToEditTask.addTextField { (alertTexfieldTitle) in
            alertTexfieldTitle.text = taskTitle
            newTaskTitle = alertTexfieldTitle
        }
        
        alertToEditTask.addTextField { (alertTexfieldDescription) in
            alertTexfieldDescription.text = taskDescription
            newTaskDescription = alertTexfieldDescription
        }
        
        let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
            TalkToServer.sharedObject.updateTask(task_id: taskID, group_id: groupID, taskName: newTaskTitle.text!, taskDescription: newTaskDescription.text!)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) in
            print("Cancel Action")
        }
        
        alertToEditTask.addAction(addAction)
        alertToEditTask.addAction(cancelAction)

        
        self.present(alertToEditTask, animated: true) {
            //do nothing
        }
    }
    
    func addNewTask(indexPath : IndexPath){
            
            let groupID         : String = dataToLoadThisTable[indexPath.section].groupData.groupID
            
            let alertToEditTask = UIAlertController(title: "Add New Task", message: nil , preferredStyle: .alert )
            
            var newTaskTitle       = UITextField()
            var newTaskDescription = UITextField()
            
            alertToEditTask.addTextField { (alertTexfieldTitle) in
                alertTexfieldTitle.placeholder = "Enter Task Title"
                newTaskTitle = alertTexfieldTitle
            }
            
            alertToEditTask.addTextField { (alertTexfieldDescription) in
                alertTexfieldDescription.placeholder = "Enter Task Description"
                newTaskDescription = alertTexfieldDescription
            }
            
            let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
                
                TalkToServer.sharedObject.createTask(group_id: groupID, taskName: newTaskTitle.text!, taskDescription: newTaskDescription.text!)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) in
                print("Cancel Action")
            }
            
            alertToEditTask.addAction(addAction)
            alertToEditTask.addAction(cancelAction)
        
            self.present(alertToEditTask, animated: true) {
                //do nothing
            }
        
    }
    
    func addNewGroup(){
        
        let alertToEditTask = UIAlertController(title: "Add New Task", message: nil , preferredStyle: .alert )
        
        var newGroupName  = UITextField()
        
        alertToEditTask.addTextField { (alertTexfieldTitle) in
            alertTexfieldTitle.placeholder = "Enter Group Name"
            newGroupName = alertTexfieldTitle
        }
        
        let addAction = UIAlertAction(title: "OK", style: .default) { (action) in
            TalkToServer.sharedObject.createGroup(groupName: newGroupName.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) in
            print("Cancel Action")
        }
        
        alertToEditTask.addAction(addAction)
        alertToEditTask.addAction(cancelAction)
        
        self.present(alertToEditTask, animated: true) {
            //do nothing
        }
    }

    
    @IBAction func logOutAction(_ sender: UIButton) {
        TalkToServer.sharedObject.tokenKeeper = ""
        TalkToServer.sharedObject.tableSections = []
        TalkToServer.sharedObject.isItFirstTimeToSetWholeData = true
        self.dismiss(animated: true) {
            //nothing
        }
    }
    
    @IBAction func addNewGroup(_ sender: UIButton) {
        self.addNewGroup()
    }
    
    @IBAction func goToGroupManager(_ sender: UIButton) {
        let groupPage = self.storyboard?.instantiateViewController(withIdentifier: "groupPage") as! GroupManagerViewController
        self.present(groupPage, animated: false) {
            //nothing
        }
    }
    
}

