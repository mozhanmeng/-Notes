//
//  ClientDetailViewPresenter.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/4.
//

import UIKit

protocol ClientView: class {
    func getTableView() -> UITableView
    func getClient() -> Client
}

class ClientDetailViewPresenter{
    
    var clientView : ClientView?
    
    var data : NSMutableArray = NSMutableArray()
    
    required init(view: ClientView) {
        
        clientView = view
        
    }
    
    func calculateHeightofTable() -> CGFloat {
        
        var height : CGFloat = 0
        
        for index in 0...2{
            
            let indexPath = IndexPath(row: index, section: 0)
            
            let rect = clientView?.getTableView().rectForRow(at: indexPath)
            
            height = height + (rect?.size.height)!;
        }
        
        return height
    }
    
    func produceUniqueFileName() -> String {
        let prefixString = clientView?.getClient()._userId!
        let guid: String = NSUUID().uuidString
        let uniqueFileName = "\(prefixString)_\(guid)"
        return uniqueFileName
    }
    
    //MARK: - ConvertTools
    func convertToNSMutableArray(selectField : [String]) -> NSMutableArray {
        let array : NSMutableArray = NSMutableArray()
        for item in selectField{
            array.add(item)
        }
        return array
    }
    
    func convertToStringSet(selectField : NSMutableArray) -> [String] {
        var arraySet : [String] = []
        for item in selectField{
            arraySet.append(item as! String)
        }
        return arraySet
    }
}
