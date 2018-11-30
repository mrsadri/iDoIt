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

class TalkToServer {
    
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
            self.getGroup()

            //TODO: write the token to the PList evenif it is ""
            /* if token == "" {present login view} else {
             1: Update self.tableRows
             2: Write tableRows to PList
             3: Reload Table
             }*/
        }
        willSet(Value) {
            if Value != "" {
                print("Token is valid, I am fetching Data")
                //present login page
            }
        }
    }
    var userData : (firstName: String, lastName: String) = ("",""){
        didSet{
            print("This is UserData: \(userData)")
            //Call VC func to write name again
            //Write name to the PList
        }
    }
    var responseKeeper : (body: JSON, header: JSON) = (body: JSON(""), header: JSON(""))
    var tableSections = [TableDataModel]()
    //SingleTone Pattern
    private init() {
        //TODO: Get token from Plist
    }
    static let sharedObject = TalkToServer.init()
    
    func register(firstName: String, lastName: String, password: String, email: String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/register"
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"] // application/json
        let bodyparameters = ["first_name"  : firstName,
                              "last_name"   : lastName,
                              "password"    : password,
                              "email"       : email]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                self.tokenKeeper = self.responseKeeper.header["token"].stringValue
                self.userData.firstName = self.responseKeeper.body  ["body"]["first_name"].stringValue
                self.userData.lastName  = self.responseKeeper.body["body"]["last_name" ].stringValue
            } else {
                self.tokenKeeper = ""
            }
        }
        
    }
    
    func login(email: String, password: String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/login"
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["email" : email ,
                              "password" : password]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6){
            print(self.responseKeeper)
            
            if self.responseKeeper.body["message"].stringValue == "ok" {
                self.tokenKeeper = self.responseKeeper.header["token"].stringValue
                self.userData.firstName = self.responseKeeper.body  ["body"]["first_name"].stringValue
                self.userData.lastName  = self.responseKeeper.body["body"]["last_name" ].stringValue
            } else {
                self.tokenKeeper = ""
            }
        }
        
    }
    
    func createGroup(groupName: String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/createGroup/"
        let headers: HTTPHeaders = ["authorization" :/* "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk"*/  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["groupName": groupName ]
        
        //localSide:
        let newSection = TableDataModel(groupData: (groupName: groupName, groupID: "0"), tasksData: [])
        self.tableSections.append(newSection)
        self.isReadyToReload = true
        //ServerSide:
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                let newSectionInTable = TableDataModel(groupData: (groupName: self.responseKeeper.body["body"]["name"].stringValue, groupID: self.responseKeeper.body["body"]["id"].stringValue), tasksData: [])
                self.tableSections.removeLast()
                self.tableSections.append(newSectionInTable)
                self.isReadyToReload = true
            } else {
                //nothing
            }
        }
    }
    
    func deleteGroup(group_id: String)  {
        
        //Since you just know the name of grups not their ID, You may need name of group and call get_Groupe and find the ID of the Group then call this func byt the ID! // another way solved this
        
        let thisUrl = "http://buzztaab.com:8081/api/deleteGroup/"
        let headers: HTTPHeaders = ["authorization" :/* "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk"*/  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            // BUG: server always rspond "OK"
            
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                for index in 0...(self.tableSections.count - 1){
                    if self.tableSections[index].groupData.groupID == group_id {
                        self.tableSections.remove(at: index)
                        //TODO: write self.tableRows to Plist and reload table
                    }
                }
            } else {
                //nothing
            }
        }
        
    }
    
    func getGroup(group_id: String = "1") {
        //- BUG: GroupId is not neccesary here, just the token is matter
        isItFirstTimeToSetWholeData = true
        
        let thisUrl = "http://buzztaab.com:8081/api/getGroup/"
        let headers: HTTPHeaders = ["authorization" : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk", */  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            // BUG: server always rspond "OK"
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                /*BUG: it will faced out of range error, the solution:
                 step 1: empty the array at first (if requst is success)
                 step 2: apend groupData 1by1 to a temp array
                 step 3: call get_Task by groupID to fill taskData in the array
                 step 4 : reload the table*/
                // BUG: IF I call get_Task, the JSONkeeper which is filled by groupData is affected, please pay attention to prevent this
                
                // 1:
                self.tableSections = []
                
                // 2:
                //count the JSON parameters in body then write a for here
                if self.responseKeeper.body["body"].count > 0 {
                    
                    for index in 0...self.responseKeeper.body["body"].count-1 {
                        
                        let groupDataM : (groupName: String, groupID: String) =
                            (groupName: self.responseKeeper.body["body"][index]["name"].stringValue,
                             groupID:   self.responseKeeper.body["body"][index]["id"  ].stringValue)
                        
                        let newElementM = TableDataModel(groupData: groupDataM, tasksData: [])

                        self.tableSections.append(newElementM)
                        
                        self.groupIDKeeperTemp.append(groupDataM.groupID)
                        
                        //                    self.tableRows[index].groupData.groupID   = self.responseKeeper.body["body"][index]["id"  ].stringValue
                        //                    self.tableRows[index].groupData.groupName = self.responseKeeper.body["body"][index]["name"].stringValue
                    }
                }
                self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.getTasksQueue), userInfo: nil, repeats: true)
                
                //                for groupIndex in 0...(self.tableRows.count - 1) {
                //                    self.get_Task(group_id: self.tableRows[groupIndex].groupData.groupID)
                //                }
                
            } else {
                //TODO: fill the frist row by this: "check the connection"
                //nothing
            }
        }
        
        //here tell to Home Screen How much does it take
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            print("check why timer is 14")
            print(self.tableSections)
            let catchTime : String = String(self.tableSections.count * 2 + 2)
            print("time to catch data: \(catchTime)")
           // self.delegetionForThisClass.setTimerFirstValue(input: howManyGroups)
        }
    }
    
    @objc func getTasksQueue(){
        print("GroupIDs : \(groupIDKeeperTemp)")
        if groupIDKeeperTemp.count > 0 {
            self.getTask(group_id: groupIDKeeperTemp[0])
            groupIDKeeperTemp.remove(at: 0)
        } else {
            timer?.invalidate()
            isReadyToReload = true
            //self.dataModelPrinter()
        }
        
    }
    
    func updateGroup(groupName: String, group_id: String){ //Change Group name
        
        //As same as "DeleteGroup" you just know the name of group not its ID
        let thisUrl = "http://buzztaab.com:8081/api/updateGroup/"
        let headers: HTTPHeaders = ["authorization" :/* "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk"*/  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["groupName":groupName, "group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            // BUG: server always rspond "OK"
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                //count the JSON parameters in body then write a for here
                for index in 0...(self.tableSections.count - 1){
                    if self.tableSections[index].groupData.groupID == group_id {
                        self.tableSections[index].groupData.groupName = groupName
                        //TODO: write self.tableRows to Plist and reload table
                    }
                }
                
                
            } else {
                //nothing
            }
        }
        
    }
    
    
    func createTask(group_id: String , taskName: String, taskDescription: String){
        //BUG: API, when create a task in the none exist group server does not respond in a proper way.
        
        let thisUrl = "http://buzztaab.com:8081/api/createTask/"
        let headers: HTTPHeaders = ["authorization" : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk" ,*/ "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ,
                              "taskName":taskName,
                              "taskDescription":taskDescription,
                              "executionTime" : "fd" ]
        //LocalSide:
        for index in 0...(self.tableSections.count - 1){
            if self.tableSections[index].groupData.groupID == group_id {
                
                let newTask = (taskName: taskName, taskID: "0", taskDescription: taskDescription, doneStatus: false)
                
                self.tableSections[index].tasksData.append(newTask)
                isReadyToReload = true
                //TODO: write self.tableRows to Plist and reload table
            }
        }
        //serverSide:
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            // BUG: server always rspond "OK"
            if self.responseKeeper.body["message"].stringValue == "ok" {
                print(self.responseKeeper)
                //count the JSON parameters in body then write a for here
                for index in 0...(self.tableSections.count - 1){
                    if self.tableSections[index].groupData.groupID == group_id {
                        
                        let newTask = (taskName: taskName, taskID: self.responseKeeper.body["body"]["id"].stringValue, taskDescription: taskDescription, doneStatus: false)
                        
                        self.tableSections[index].tasksData.removeLast()
                        self.tableSections[index].tasksData.append(newTask)
                        self.isReadyToReload = true

                        //TODO: write self.tableRows to Plist and reload table
                    }
                }
                
                
            } else {
                //nothing
            }
        }
    }
    
    var placeOfRemovedItem : (group: Int, task: Int)?
    func deleteTask(task_id: String) {
        
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
        
        let thisUrl = "http://buzztaab.com:8081/api/deleteTask/"
        let headers: HTTPHeaders = ["authorization" : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk", */  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["task_id": task_id ]
        
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
    }
    
    func getTask(group_id : String) {
        
        let thisUrl = "http://buzztaab.com:8081/api/getTask/"
        let headers: HTTPHeaders = ["authorization" : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk", */  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["group_id": group_id ]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            // BUG: server always rspond "OK"
            if self.responseKeeper.body["message"].stringValue == "ok" {
                if self.responseKeeper.body["body"].count != 0 {
                    print(self.responseKeeper.body["body"])
                    
                }
                /*TODO:
                 1: empty the list of tasks (ie TaskData)
                 2: Find the section(ie Group) by groupID
                 3: then apend items 1by1 to it*/
                
                //count the JSON parameters in body then write a for here
                if self.responseKeeper.body["body"].count != 0 {
                    //1
                    for indexM in 0...self.tableSections.count-1 {
                        if self.tableSections[indexM].groupData.groupID == group_id {
                            self.tableSections[indexM].tasksData = []
                        }
                    }
                    for index in 0...self.responseKeeper.body["body"].count-1 {
                        let taskDataM = (taskName: self.responseKeeper.body["body"][index]["taskName"       ].stringValue,
                                         taskID:   self.responseKeeper.body["body"][index]["id"             ].stringValue,
                                         taskDescription:  self.responseKeeper.body["body"][index]["taskDescription"].stringValue,
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
        }
        
    }
    
    func updateTask(task_id : String, group_id : String , taskName : String , taskDescription : String ) {
        //BUG: even if the task or the qroup does not exist, server respond "OK"
        //BUG: there are two groupID
        
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
        
        let thisUrl = "http://buzztaab.com:8081/api/updateTask/"
        let headers: HTTPHeaders = ["authorization" : /*"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiNzYwYWM4ZWQtMzhkMy00ZjUzLWE3YjItOWFkOWIzYmRhNjRhIiwiaWF0IjoxNTM5MjUwNTg2fQ.exeb-WXsM06aWMtInkQcaoK7hKJ9NGrUpQUsHkKBdIk", */  "Bearer \(tokenKeeper)",
            "Content-Type": "application/x-www-form-urlencoded"]
        let bodyparameters = ["task_id":task_id,
                              "groupId":"1",
                              "group_id":group_id ,
                              "taskName":taskName,
                              "taskDescription":taskDescription,
                              "executionTime" : "fdss"]
        
        requester(url: thisUrl, headers: headers, bodyparameters: bodyparameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
        }
    }
    
    //this func will fetch all data at first step from server
    func fetchAll() { //get_Group is doing the same action, so I skip this one
        /*
         1: call get_Group
         2: by every groupID call get task
         3: the self.tableRows will fill automaticaly
         4: write data to the PList
         5: reload the Table
         */
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
        } else {
            print("dataModelPrinter can not work")
        }
    }
    
}
//- Note: SingleTone pattern is not suitable for this case and I have to use delegation pattern
//- TODO: Define a requester func to call alamofire with header, body, and url and return bodyJSON and HeaderJSON :Done
//- TODO: if token == "" ban all this funcs: get_Group, createGroup, ...
//- TODO: if JSON message == "ok" { successFlag = true } :Done in other way
//- TODO: Encapsulate this Class (ie these methodes: get_Group, createGroup, ...) with reloadTable Data, then move requester method to TalkToServer Class
//- TODO: reload tabelData in success clouser in all methodes
//- TODO: Impliment Base URL
//- Challenge: Update Part of a task
//- Challenge: find task position by its title name

