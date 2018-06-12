//
//  ContactViewPresenter.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/24.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import SkyFloatingLabelTextField

protocol ContactView: class {
    func returnTitleTextfiledText() -> String
    func returnSearchResult() -> NSMutableArray
    func setTable()
    func removeEditView()
    func reloadTableview()
    func pushToDetail(client : Client)
    func createSearchBar()
    func startAnimating(type : Int) -> Void
    func stopAnimating()
    func setNavigationBtn()
    func setLeftNavigationBtn()
    func setTabBarIconAndTitle()
}

//MARK: - renew data
protocol renewDataDelegate {
    func updateLocalData(newData : Client)
}

class ContactViewPresenter : renewDataDelegate{
    
    var contactView : ContactView?
    
    var data : NSMutableArray = NSMutableArray()
    
    required init(view: ContactView) {
        
        contactView = view

        contactView?.startAnimating(type: 4)
        
        DynamoDBManager._sharedManager.getData(model : Client.self,indexName : "GetUserByName", completion: {(_ task : AWSTask<AWSDynamoDBPaginatedOutput>?) -> Void in
            
            if let paginatedOutput = task?.result {
                for index in 0..<paginatedOutput.items.count {
                    self.data.add(paginatedOutput.items[index])
                }
                DispatchQueue.main.async {
                    self.contactView?.setTable()
                    self.contactView?.createSearchBar()
                    self.contactView?.stopAnimating()
                    self.contactView?.setNavigationBtn()
                    self.contactView?.setLeftNavigationBtn()
                    self.contactView?.setTabBarIconAndTitle()
                }
            }
        })
    }
    
    @objc func pushAddClients() -> Void {
        
        if contactView != nil{
            contactView?.removeEditView()
        }

        let client : Client = Client()
        
        client._userId = AWSIdentityManager.default().identityId
        client._fullname = String(format: "%@", self.contactView!.returnTitleTextfiledText() as CVarArg)
        client._address = ["Address"]
        client._mobile = ["Mobile Phone Number"]
        client._chineseIDNumber = ["ID number"]
        
        DynamoDBManager._sharedManager.saveData(model: client) {
            self.data.add(client)
            DispatchQueue.main.async {
                self.contactView?.reloadTableview()
                self.contactView?.pushToDetail(client : client)
            }
        }
    }

    
    func deleteItemInServer(indexPath : IndexPath) -> Void{
        
        let clientToDelete = (self.data[indexPath.row] as! Client)

        DynamoDBManager._sharedManager.deleteData(model: clientToDelete){
            self.data.removeObject(at: indexPath.row)
            DispatchQueue.main.async {
                self.contactView?.reloadTableview()
            }
            CommonUseClass._sharedManager.sendAlert(msg: "Delete Succssuful", view: self.contactView as! UIViewController)
        }
    }
    
    func updateLocalData(newData: Client) -> Void {
        for index in 0...self.data.count-1 {
            if let client = (self.data[index] as? Client){
                if client._fullname == newData._fullname{
                    self.data[index] = newData
                    DispatchQueue.main.async {
                        self.contactView?.reloadTableview()
                    }
                }
            }
        }
    }
    
    func removeDupilicatedContact() -> Void {
        
        let originalObjects : NSMutableArray = NSMutableArray()
        let searchResult = contactView?.returnSearchResult()
        let count : Int = (searchResult?.count)!
        
        for index in 0..<count
        {
            let original = searchResult![index] as! Client
            
            if originalObjects.count == 0
            {
                originalObjects.add(original)
            }
            
            for num in 0...originalObjects.count
            {
                let client = originalObjects[num] as! Client
                
                if original._fullname! == client._fullname!
                {
                    break
                }
                
                if num == originalObjects.count - 1
                {
                    originalObjects.add(original)
                }
                
            }
        }
        
        for index in 0..<count
        {
            let item : Client = searchResult![index] as! Client
            
            for num in 0..<originalObjects.count
            {
                let original : Client = originalObjects[num] as! Client
                
                if original._fullname! == item._fullname!
                {
                    if index == (searchResult?.count)!-1
                    {
                        searchResult?.removeAllObjects()
                        searchResult?.addObjects(from: originalObjects as! [Any])
                    }
                }
            }
        }
    }
}
