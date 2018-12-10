//
//  PListControl.swift
//  iDoIt
//
//  Created by MSadri on 12/6/18.
//  Copyright © 2018 MSadri. All rights reserved.
//

import Foundation

class PListControl {
    var userData : (token : String, firstName: String, lastName: String) = (token: "" , firstName: "", lastName: "")
    
    static let sharedObject = PListControl()
    private init () {
        pListCreation()
        getUserDataPlist()
    }
    
    let fileManager = FileManager.default
    var pathUserDataPList : String = ""
    var pathWholeDataPList : String = ""
    private func pListCreation() {
        
        let documentDirectoryU = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        self.pathUserDataPList = documentDirectoryU.appending("/UserData.plist")
        print(documentDirectoryU)
        
        let documentDirectoryW = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        self.pathWholeDataPList = documentDirectoryW.appending("/WholeData.plist")
        print(documentDirectoryW)
        
        if (!fileManager.fileExists(atPath: pathUserDataPList)) {
            setZeroValuToUserDeflautPList()
            //            let success:Bool = plistContent.write(toFile: pathWholeDataPList, atomically: true)
            //            if success {
            //                print("file has been created!")
            //            }else{
            //                print("unable to create the file")
            //            }
        } else {
            print("file already exist")
        }
    }
    
    
    func setZeroValuToUserDeflautPList(){
        input = ["token": "", "firstName":"","lastName":""]
        writeToPlist(toWhere: .UserData)
        getUserDataPlist()
    }

    func updateUserDataPlist(token : String , firstName: String , lastName: String ) {
        input = ["token" : token, "firstName" : firstName, "lastName" : lastName]
        writeToPlist(toWhere: .UserData)
    }
    
    func getUserDataPlist() {
        let data = readFromUserDataPList()
        //Warning
        userData =  (token: (data["token"])! , firstName: (data["firstName"])!, lastName: (data["lastName"])!)
    }
    
    enum WhichPList {
        case UserData
        case WholeData
    }
    
    var input : Any?
    private func writeToPlist(toWhere: WhichPList)  {
        
        var success = Bool()
        if toWhere == .WholeData{
            let thisInput = self.input! as! [[String]]
            let plistContent = NSArray(array: thisInput)
            plistContent.write(toFile: pathWholeDataPList, atomically: true)
            success = plistContent.write(toFile: pathWholeDataPList, atomically: true)
        } else {
            let thisInput = self.input! as! [String : String]
            let plistContent = NSDictionary(dictionary: thisInput)
            plistContent.write(toFile: pathUserDataPList, atomically: true)
            success = plistContent.write(toFile: pathUserDataPList, atomically: true)
            
        }
        
        if success {
            print("Data is Written")
        }else{
            print("There is a problem with \(toWhere) PList")
        }
        
    }
    
    func readFromUserDataPList () -> [String : String] {
        
        var returner : [String : String] = [:]
        
        if let dic = NSDictionary(contentsOfFile: pathUserDataPList) as? [String: String]{
            returner = dic
        }
        print(returner)
        return returner
    }
    
    func readFromWholeDataPList() -> [[String]] {
        
        var returner : [[String]] = []
        
        if let array = NSArray(contentsOfFile: pathWholeDataPList) as? [[String]] {
            returner = array
        }
        print(returner)
        return returner
    }
    
}
