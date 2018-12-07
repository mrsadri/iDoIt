//
//  TalkToServer.swift
//  ToDoList
//
//  Created by MSadri on 11/12/18.
//  Copyright © 2018 MSadri. All rights reserved.
//
import SwiftyJSON
import Alamofire
import Foundation

var wholeDate = [
    TableDataModel(groupData : (groupName: "Group", groupID: "") , tasksData: [(taskName: "String", taskID: "1", taskDescription: "String", doneStatus: true )] ),
    TableDataModel(groupData : (groupName: "Group", groupID: "") , tasksData: [(taskName: "String", taskID: "1", taskDescription: "String", doneStatus: true )] )
]

protocol toAccessHomeFunctions {
    func loadTheApplication()
    func setTimerFirstValue(input: String)
}

class DataManager {
    
    var delegateToAcessTableView : AccessToTableView!
    var delegateToAccessLoginPage : AccessToLoginRegistrationPage!
    
    var timer:Timer?
    var groupIDKeeperTemp : [String] = []
    
    var isItFirstTimeToSetWholeData : Bool?
    var isReadyToReload : Bool = false {
        willSet(new){
            if new {
                self.dataModelPrinter()
                wholeDate = tableSections
            }
            
            if isItFirstTimeToSetWholeData! {
                delegateToAccessLoginPage.loadTheApplication()
                isItFirstTimeToSetWholeData = false
                
                /* 1. Inject Data step by Step Through classe te aproach it to "itemsToReloadTable"
                 (as example reWrite PageIndex to fetch its Owndata again and reload the table)*/
                //accessToPageCellFromTalkToserver.resetPageIndex()
            } else {
                self.delegateToAcessTableView.reloadTableData()
                
            }
            
        }
    }
    
    var tokenKeeper : String = "" {
        didSet{
            print("The new ttoken is \"\(tokenKeeper)\"")
            if tokenKeeper != "" {
                // After setting Setting UserData, the token will be written to plist
                self.getGroup()
            } else {
            }
            
            //TODO: write the token to the PList evenif it is ""
            /* if token == "" {present login view} else {
             1: Update self.tableRows
             2: Write tableRows to PList
             3: Reload Table
             }*/
        }
        willSet(Value) {
            if Value == "" {
                PListControl.sharedObject.setZeroValuToUserDeflautPList()
            }
        }
    }
    var userData : (firstName: String, lastName: String) = ("",""){
        didSet{
            PListControl.sharedObject.updateUserDataPlist(token: tokenKeeper, firstName: userData.firstName, lastName: userData.lastName)
            //Call VC func to write name again
            //Write name to the PList
        }
    }
    var responseKeeper : (body: JSON, header: JSON) = (body: JSON(""), header: JSON(""))
    var tableSections = [TableDataModel]()  {
        didSet{
        }
    }
    
    
    private init() {
        print(PListControl.sharedObject)
    }
    
    static let sharedObject = DataManager.init()
    
    func register(firstName: String, lastName: String, password: String, email: String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/register"
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"] // application/json
        let bodyparameters = ["first_name"  : firstName,
                              "last_name"   : lastName,
                              "password"    : password,
                              "email"       : email]
        
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                if self.responseKeeper.body["message"].stringValue == "ok" {
                    self.tokenKeeper = self.responseKeeper.header["token"].stringValue
                    self.userData.firstName = self.responseKeeper.body  ["body"]["first_name"].stringValue
                    self.userData.lastName  = self.responseKeeper.body["body"]["last_name" ].stringValue
                } else {
                    self.tokenKeeper = ""
                    print("Registration Faild :X")
                    //TODO: Allert user to try again and refresh thir fields
                    self.delegateToAccessLoginPage.changeAvabilityOfButton!(to: true)
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/login"
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["email" : email ,
                              "password" : password]
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                if self.responseKeeper.body["message"].stringValue == "ok" {
                    self.tokenKeeper = self.responseKeeper.header["token"].stringValue
                    self.userData.firstName = self.responseKeeper.body  ["body"]["first_name"].stringValue
                    self.userData.lastName  = self.responseKeeper.body["body"]["last_name" ].stringValue
                } else {
                    self.tokenKeeper = ""
                    print("Connection Matters at login process")
                    //TODO: Active Allert to Try Again
                    self.delegateToAccessLoginPage.changeAvabilityOfButton!(to: true)
                }
            }
        }
    }
    
    func createGroup(groupName: String) {
        
        //localSide:
        let newSection = TableDataModel(groupData: (groupName: groupName, groupID: "0"), tasksData: [])
        self.tableSections.append(newSection)
        self.isReadyToReload = true
        
        //ServerSide:
        let thisUrl = "http://buzztaab.com:8081/api/createGroup/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["groupName": groupName ]
        
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                if self.responseKeeper.body["message"].stringValue == "ok" {
                    let newSectionInTable = TableDataModel(groupData: (groupName: self.responseKeeper.body["body"]["name"].stringValue, groupID: self.responseKeeper.body["body"]["id"].stringValue), tasksData: [])
                    self.tableSections.removeLast()
                    self.tableSections.append(newSectionInTable)
                    self.isReadyToReload = true
                } else {
                    //nothing
                }
                //---
            }
        }
    }
    
    func deleteGroup(group_id: String)  {
        
        //LocalSide:
        var placeOfRemovedGroup = Int()
        for index in 0...(self.tableSections.count - 1){
            if self.tableSections[index].groupData.groupID == group_id {
                placeOfRemovedGroup = index
                //TODO: write self.tableRows to Plist and reload table
            }
        }
        self.tableSections.remove(at: placeOfRemovedGroup)
        isReadyToReload = true
        
        //ServerSide:
        let thisUrl = "http://buzztaab.com:8081/api/deleteGroup/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
    }
    
    func getGroup(group_id: String = "1") {
        //- BUG: GroupId is not neccesary here, just the token is matter
        isItFirstTimeToSetWholeData = true
        
        let thisUrl = "http://buzztaab.com:8081/api/getGroup/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                // BUG: server always rspond "OK"
                if self.responseKeeper.body["message"].stringValue == "ok" {
                    /*BUG: it will faced out of range error, the solution:
                     step 1: empty the array at first (if requst is success)
                     step 2: append groupData 1by1 to a temp array
                     step 3: call get_Task by groupID to fill taskData in the array
                     step 4 : reload the table*/
                    
                    // 1:
                    self.tableSections = []
                    
                    // 2:
                    //count the JSON parameters in body then write a for here
                    if self.responseKeeper.body["body"].count > 0 {
                        
                        self.groupIDKeeperTemp = []
                        for index in 0...self.responseKeeper.body["body"].count-1 {
                            
                            let groupDataM : (groupName: String, groupID: String) =
                                (groupName: self.responseKeeper.body["body"][index]["name"].stringValue,
                                 groupID:   self.responseKeeper.body["body"][index]["id"  ].stringValue)
                            
                            let newElementM = TableDataModel(groupData: groupDataM, tasksData: [])
                            self.tableSections.append(newElementM)
                            self.groupIDKeeperTemp.append(groupDataM.groupID)
                        }
                    }
                    self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.getTasksQueue), userInfo: nil, repeats: true)
                } else {
                    print("User is not Legged in")
                    //nothing
                }
                //---
                //TODO: impliment Loading Bar |||| here tell to Home Screen How much does it take
            }
        }
    }
    
    @objc func getTasksQueue(){
        if groupIDKeeperTemp.count > 0 {
            self.getTask(group_id: groupIDKeeperTemp[0])
            groupIDKeeperTemp.remove(at: 0)
        } else {
            timer?.invalidate()
            isReadyToReload = true
        }
    }
    
    func updateGroup(groupName: String, group_id: String){ //Change Group name
        
        //localSide:
        for index in 0...(self.tableSections.count - 1) {
            if self.tableSections[index].groupData.groupID == group_id {
                self.tableSections[index].groupData.groupName = groupName
            }
            self.isReadyToReload = true
        }
        
        //serverSide:
        let thisUrl = "http://buzztaab.com:8081/api/updateGroup/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["groupName":groupName, "group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)        
    }
    
    func createTask(group_id: String , taskName: String, taskDescription: String){
        //BUG: API, when create a task in the none exist group server does not respond in a proper way.
        
        //LocalSide:
        for index in 0...(self.tableSections.count - 1){
            if self.tableSections[index].groupData.groupID == group_id {
                
                let newTask = (taskName: taskName, taskID: "0", taskDescription: taskDescription, doneStatus: false)
                
                self.tableSections[index].tasksData.append(newTask)
                isReadyToReload = true
            }
        }
        
        //serverSide:
        let thisUrl = "http://buzztaab.com:8081/api/createTask/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id"        : group_id ,
                              "taskName"        :taskName,
                              "taskDescription" :taskDescription,
                              "executionTime"   : "fd" ]
        
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                // BUG: server always rspond "OK"
                if self.responseKeeper.body["message"].stringValue == "ok" {
                    //count the JSON parameters in body then write a for here
                    for index in 0...(self.tableSections.count - 1){
                        if self.tableSections[index].groupData.groupID == group_id {
                            
                            let newTask = (taskName: taskName, taskID: self.responseKeeper.body["body"]["id"].stringValue, taskDescription: taskDescription, doneStatus: false)
                            
                            self.tableSections[index].tasksData.removeLast()
                            self.tableSections[index].tasksData.append(newTask)
                            self.isReadyToReload = true
                        }
                    }
                } else {
                    //nothing
                }
                //---
            }
        }
    }
    
    var placeOfRemovedItem : (group: Int, task: Int)?
    func deleteTask(task_id: String) {
        
        //localSide:
        {
            //count the JSON parameters in body then write a for here
            for gIndex in 0...(self.tableSections.count - 1){
                if self.tableSections[gIndex].tasksData.count != 0 {
                    for tIndex in 0...(self.tableSections[gIndex].tasksData.count - 1) {
                        if (self.tableSections[gIndex].tasksData[tIndex].taskID == task_id){
                            self.placeOfRemovedItem = (group: gIndex, task: tIndex)
                        }//End If // find item
                    }// End For tIndex
                }//End If (!is group empty)
            }//End For gIndex
            //TODO: unwrapp placeOfRemovedItem by Guard let
            self.tableSections[self.placeOfRemovedItem!.group].tasksData.remove(at: self.placeOfRemovedItem!.task)
            self.isReadyToReload = true
            //TODO: write self.tableRows to Plist and reload table
        }()
        
        //serverSide:
        let thisUrl = "http://buzztaab.com:8081/api/deleteTask/"
        let headers: HTTPHeaders = ["authorization" :  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["task_id": task_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
    }
    
    func getTask(group_id : String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/getTask/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        Alamofire.request(thisUrl, method: .post, parameters: bodyparameters , headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                //---
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                let ThisResponseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
                //---
                
                if ThisResponseKeeper.body["message"].stringValue == "ok" {
                    if ThisResponseKeeper.body["body"].count != 0 {
                    }
                    /*TODO:
                     1: empty the list of tasks (ie TaskData)
                     2: Find the section(ie Group) by groupID
                     3: then apend items 1by1 to it*/
                    
                    //count the JSON parameters in body then write a for here
                    if ThisResponseKeeper.body["body"].count != 0 {
                        //1
                        for indexM in 0...self.tableSections.count-1 {
                            if self.tableSections[indexM].groupData.groupID == group_id {
                                self.tableSections[indexM].tasksData = []
                            }
                        }
                        for index in 0...ThisResponseKeeper.body["body"].count-1 {
                            let taskDataM = (taskName: ThisResponseKeeper.body["body"][index]["taskName"       ].stringValue,
                                             taskID:   ThisResponseKeeper.body["body"][index]["id"             ].stringValue,
                                             taskDescription:  ThisResponseKeeper.body["body"][index]["taskDescription"].stringValue,
                                             doneStatus: false)
                            //2: Find the section(ie Group) by groupID
                            for indexM in 0...self.tableSections.count-1 {
                                if self.tableSections[indexM].groupData.groupID == group_id {
                                    //3
                                    self.tableSections[indexM].tasksData.append(taskDataM)
                                }
                            }
                        }
                    }
                    //TODO: write self.tableRows to Plist and reload table
                    
                } else {
                    //nothing
                    //self.timer?.invalidate()
                }
                //---
            }
        }
    }
    
    func updateTask(task_id : String, group_id : String , taskName : String , taskDescription : String ) {
        //BUG: even if the task or the qroup does not exist, server respond "OK"
        //BUG: there are two groupID
        
        //localSide:
        if self.tableSections.count > 0 {
            for i in 0...self.tableSections.count-1 {
                if group_id == self.tableSections[i].groupData.groupID {
                    
                    //find the task
                    if self.tableSections[i].tasksData.count > 0 {
                        for j in 0...self.tableSections[i].tasksData.count-1 {
                            if task_id == self.tableSections[i].tasksData[j].taskID {
                                
                                //change the task
                                let newTask = (taskName: taskName, taskID: task_id, taskDescription: taskDescription, doneStatus: false)
                                //BUG: doneState cannot be changed on server side
                                self.tableSections[i].tasksData[j] = newTask
                                self.isReadyToReload = true
                            }
                        }
                    }
                }
            }
        }
        
        //ServerSide:
        let thisUrl = "http://buzztaab.com:8081/api/updateTask/"
        let headers: HTTPHeaders = ["authorization" : "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["task_id":task_id,
                              "groupId":"1",
                              "group_id":group_id ,
                              "taskName":taskName,
                              "taskDescription":taskDescription,
                              "executionTime" : "fdss"]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
    }
    
    func requester(url: String, headers: HTTPHeaders, bodyparameters: [String : String] ) {
        
        
        Alamofire.request( url, method: .post , parameters: bodyparameters , headers: headers).responseJSON{ response in
            if response.result.isSuccess{
                let jsonKeeperBody : JSON = JSON(response.result.value!)
                let jsonKeeperHeader : JSON = JSON(response.response!.allHeaderFields)
                self.responseKeeper = (body: jsonKeeperBody, header: jsonKeeperHeader)
            } else {
                print("Error: \(String(describing: response.result.error))")
                let defaultBodyJSON : JSON = JSON( ["message": "Server Out Of Reach"])
                self.responseKeeper = ((body: defaultBodyJSON, header: JSON("")))
            }
        }
    }
    
    func dataModelPrinter () {
        if tableSections.count > 0 {
            for i in 0...tableSections.count-1 {
                print("---------------------------------")
                print("Group ID: \(tableSections[i].groupData.groupID)\tGroup name: \(tableSections[i].groupData.groupName)")
                print(".................................")
                if tableSections[i].tasksData.count > 0 {
                    for j in 0...tableSections[i].tasksData.count-1 {
                        print("Task Name: \(tableSections[i].tasksData[j].taskName)")
                    }
                }
            }
        }
    }
    
}
//valid toket : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk", */
//- Note: SingleTone pattern is not suitable for this case and I have to use delegation pattern
//- TODO: Define a requester func to call alamofire with header, body, and url and return bodyJSON and HeaderJSON :Done
//- TODO: if token == "" ban all this funcs: get_Group, createGroup, ...
//- TODO: if JSON message == "ok" { successFlag = true } :Done in other way
//- TODO: Encapsulate this Class (ie these methodes: get_Group, createGroup, ...) with reloadTable Data, then move requester method to TalkToServer Class
//- TODO: reload tabelData in success clouser in all methodes
//- TODO: Impliment Base URL
//- Challenge: Update Part of a task
//- Challenge: find task position by its title name

