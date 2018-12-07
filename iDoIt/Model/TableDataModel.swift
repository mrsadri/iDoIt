//
//  TableDataModel.swift
//  ToDoList
//
//  Created by MSadri on 11/12/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import Foundation

struct TableDataModel {
    var groupData : (groupName: String, groupID: String)
    var tasksData: [(taskName: String, taskID: String, taskDescription: String, doneStatus: Bool )]
    // if I want sort them by time, I have to add time attribute here (to obove data)
}
