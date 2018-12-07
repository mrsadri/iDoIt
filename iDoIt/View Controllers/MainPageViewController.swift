//
//  ViewController.swift
//  iDoIt
//
//  Created by MSadri on 11/28/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import UIKit

@objc protocol AccessToTableView {
    func reloadTableData()
    func selfDismiss()
}

class MainPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccessToTableView {
    
    static var delegateOfGroupManagerPage : AccessToGroupManagerPage!
    
    @IBOutlet weak var userNameLabel: UILabel!
    func setUserNameLabel(){
        let attributedText = NSMutableAttributedString(string: "\(DataManager.sharedObject.userData.firstName) \(DataManager.sharedObject.userData.lastName)", attributes: [NSAttributedString.Key.font: UIFont.init(name: "ChalkBoard SE", size: 26) ?? UIFont.systemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.white])
        userNameLabel.attributedText = attributedText
    }
    var dataToLoadThisTable :  [TableDataModel] = [ TableDataModel(groupData: (groupName: "Loading...", groupID: "Loading..."), tasksData: [(taskName: "Tasks are loading...", taskID: "1", taskDescription: "Wait..", doneStatus: true )] ) ] {
        didSet{
            print("new Data is set")
        }
    }
    
    var isGroupManagerPageActivated = Bool()
    
    func reloadTableData() {
        dataToLoadThisTable = wholeDate
        if isGroupManagerPageActivated {
            MainPageViewController.delegateOfGroupManagerPage.reloadTableData()
            self.mainTable.reloadData()
            //self.delegateOfGroupManagerPage.reloadTableData()
            print("---- \nDebug:nil is reported here, I want to know when this is called")
        } else {
            self.mainTable.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataToLoadThisTable.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var thisTitle = String()
        thisTitle = dataToLoadThisTable[section].groupData.groupName
        return thisTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.init(name: "ChalkBoard SE", size: 15) ?? UIFont.systemFont(ofSize: 15)
        header.textLabel!.textColor = UIColor.black
        //        header.backgroundView?.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 0.8)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var howManyCells = Int()
        howManyCells = dataToLoadThisTable[section].tasksData.count + 1
        return howManyCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < dataToLoadThisTable[indexPath.section].tasksData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "thisCell", for: indexPath)
            
            let attributedText = NSMutableAttributedString(string: dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskName, attributes: [NSAttributedString.Key.font: UIFont.init(name: "ChalkBoard SE", size: 17) ?? UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
            
            cell.textLabel?.attributedText = attributedText
            cell.imageView?.image = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].doneStatus ? UIImage(named: "Done-True-iCon") : UIImage(named: "Done-False-iCon")
            cell.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastCell", for: indexPath)
            cell.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            //remove From server
            DataManager.sharedObject.deleteTask(task_id: self.dataToLoadThisTable[editActionsForRowAt.section].tasksData[editActionsForRowAt.row].taskID)
        }
        remove.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 0.8)
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editTask(indexPath: editActionsForRowAt)
        }
        edit.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 0.8)
        
        let doneText : String = wholeDate[editActionsForRowAt.section].tasksData[editActionsForRowAt.row].doneStatus ? "UnDone" : "Done"
        let done = UITableViewRowAction(style: .normal, title: doneText) { action, index in
            wholeDate[editActionsForRowAt.section].tasksData[editActionsForRowAt.row].doneStatus = !wholeDate[editActionsForRowAt.section].tasksData[editActionsForRowAt.row].doneStatus
            self.reloadTableData()
        }
        done.backgroundColor = UIColor(red: 132/255 , green: 180/255 , blue: 196/255, alpha: 1)
        
        return [done, edit, remove]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == dataToLoadThisTable[indexPath.section].tasksData.count {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == dataToLoadThisTable[indexPath.section].tasksData.count {
            self.addNewTask(indexPath: indexPath)
        } else {
            
            let taskTitle       : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskName
            let taskDescription : String = dataToLoadThisTable[indexPath.section].tasksData[indexPath.row].taskDescription
            
            let alert = UIAlertController(title: taskTitle, message: taskDescription , preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "Edit Task", style: .default) { (action) in
                print("Edit Task")
                //---
                self.editTask(indexPath: indexPath)
                //---
                
            }
            
            let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                let taskId = self.dataToLoadThisTable[indexPath.section].tasksData[indexPath.item].taskID
                DataManager.sharedObject.deleteTask(task_id: taskId)
            }
            
            let doneText : String = wholeDate[indexPath.section].tasksData[indexPath.row].doneStatus ? "UnDone" : "Done"
            let doneAction = UIAlertAction(title: doneText, style: .default) { (action) in
                wholeDate[indexPath.section].tasksData[indexPath.row].doneStatus = !wholeDate[indexPath.section].tasksData[indexPath.row].doneStatus
                self.reloadTableData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            
            alert.addAction(removeAction)
            alert.addAction(editAction)
            alert.addAction(doneAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true) {
                //do nothing
            }
        }
        self.mainTable.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isGroupManagerPageActivated = false
    }
    
    @IBOutlet weak var mainTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTable.delegate = self
        mainTable.dataSource = self
        self.mainTable.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
        DataManager.sharedObject.delegateToAcessTableView = self
        self.dataToLoadThisTable = wholeDate
        setUserNameLabel()
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
            DataManager.sharedObject.updateTask(task_id: taskID, group_id: groupID, taskName: newTaskTitle.text!, taskDescription: newTaskDescription.text!)
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
            
            DataManager.sharedObject.createTask(group_id: groupID, taskName: newTaskTitle.text!, taskDescription: newTaskDescription.text!)
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
            print("Cancel Action")
        }
        
        alertToEditTask.addAction(addAction)
        alertToEditTask.addAction(cancelAction)
        
        self.present(alertToEditTask, animated: true) {
            //do nothing
        }
    }
    
    
    @IBAction func logOutAction(_ sender: UIButton) {
        DataManager.sharedObject.tokenKeeper = ""
        DataManager.sharedObject.tableSections = []
        DataManager.sharedObject.isItFirstTimeToSetWholeData = true
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
        self.isGroupManagerPageActivated = true
    }
    
    func selfDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

