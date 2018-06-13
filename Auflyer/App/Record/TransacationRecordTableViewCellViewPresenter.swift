//
//  TransacationRecordViewPresenter.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/30.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn

enum NSComparisonResult : Int {
    case OrderedAscending
    case OrderedSame
    case OrderedDescending
}

protocol TransacationRecordView: class {
    func setTable()
    func makeData()
    func startAnimating(type : Int) -> Void
    func stopAnimating()
    func getTable() -> UITableView
}

class TransacationRecordViewPresenter {
    
    var transacationRecordView : TransacationRecordView?
    
    var cellsTotalMutableArray : NSMutableArray = NSMutableArray()
    var sectionTotal : NSMutableArray = NSMutableArray()
    var numberOfOrderInDate = [Int]()
    var cellsTotal : [[Double]] = []
    var totalData : [[TransacationRecord]] = []
    var data : [TransacationRecord] = []
    
    required init(view: TransacationRecordView) {
        
        transacationRecordView = view
        
        initilaise()
    }
    
    func initilaise() -> Void {
        transacationRecordView?.startAnimating(type: 4)
        DynamoDBManager._sharedManager.getData(model : TransacationRecord.self,indexName : "GetTransacationRecordByDate", completion: {(_ task : AWSTask<AWSDynamoDBPaginatedOutput>?) -> Void in
            
            
            if let paginatedOutput = task?.result {
                for index in 0..<paginatedOutput.items.count {
                    self.data.append(paginatedOutput.items[index] as! TransacationRecord)
                    self.sortDatebyDate()
                }
                DispatchQueue.main.async {
                    self.distributeDataByDate(data : self.data)
                    self.transacationRecordView?.makeData()
                    self.transacationRecordView?.setTable()
                    self.transacationRecordView?.stopAnimating()
                    self.cauculateTotalResults()
                    self.distributeInto2DArray()
                }
            }
        })
    }
    
    func deleteItemInServer(indexPath : IndexPath) -> Void{
        
        let recordToDelete = (self.totalData[indexPath.section][indexPath.row])
        
        DynamoDBManager._sharedManager.deleteData(model: recordToDelete){
            self.totalData[indexPath.section].remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.refresh()
            }
            CommonUseClass._sharedManager.sendAlert(msg: "Delete Succssuful", view: self.transacationRecordView as! UIViewController)
        }
    }
    
    func sortDatebyDate() -> Void {
        self.data.sort(by: { ($0._date)?.convertToNSDateFromString().compare((($1._date)?.convertToNSDateFromString())!) == .orderedAscending })
    }
    
    @objc func refresh() -> Void {
        
        self.data.removeAll()
        self.numberOfOrderInDate.removeAll()
        self.totalData.removeAll()
        self.cellsTotalMutableArray.removeAllObjects()
        self.cellsTotal.removeAll()
        self.sectionTotal.removeAllObjects()
        
        self.transacationRecordView?.startAnimating(type: 4)
        DynamoDBManager._sharedManager.getData(model : TransacationRecord.self,indexName : "GetTransacationRecordByDate", completion: {(_ task : AWSTask<AWSDynamoDBPaginatedOutput>?) -> Void in
            
            
            if let paginatedOutput = task?.result {
                for index in 0..<paginatedOutput.items.count {
                    self.data.append(paginatedOutput.items[index] as! TransacationRecord)
                    self.sortDatebyDate()
                }
                DispatchQueue.main.async {
                    self.distributeDataByDate(data : self.data)
                    self.cauculateTotalResults()
                    self.distributeInto2DArray()
                    self.transacationRecordView?.makeData()
                    self.transacationRecordView?.getTable().reloadData()
                    self.transacationRecordView?.stopAnimating()
                }
            }
        })
    }
    
    func addClient() -> Void {
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let transacationRecord : TransacationRecord = TransacationRecord()
        
        var dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEEE, dd, MMMM, yyyy， HH:mm:ss"
        dateformatter.locale = Locale.current
        let date = dateformatter.string(from: NSDate() as Date)
        
        dateformatter.dateFormat = "HH:mm:ss"
        let time = dateformatter.string(from: NSDate() as Date)
        
        dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd, MMMM, yyyy"
        let fullTime = dateformatter.string(from: NSDate() as Date)
        
        transacationRecord._userId = AWSIdentityManager.default().identityId
        transacationRecord._date = date
        transacationRecord._fullTime = fullTime
        transacationRecord._time = time
        transacationRecord._productNames = ["coles", "woolworth", "Big W", "Big W", "Big W", "Big W"]
        transacationRecord._buyer = "Alan"
        transacationRecord._store = "Big W"
        transacationRecord._priceBuyIn = ["1","3","4","1","3","4"]
        transacationRecord._priceSellOut =  ["3","4","6","1","3","4"]
        //Save a item
        dynamoDbObjectMapper.save(transacationRecord).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Notice", message: "Save Successful", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                    }))
                    
                    //                    self.present(alert, animated: true, completion: nil)
                })
            }
            return nil
        })
    }
    
    func distributeDataByDate(data : [TransacationRecord]) -> Void {
        
        let arrayByDate : NSMutableArray = NSMutableArray()
        numberOfOrderInDate = [Int]()
        
        for transacationRecord in data{
            if !arrayByDate.contains(transacationRecord._fullTime!)
            {
                arrayByDate.add(transacationRecord._fullTime!)
            }
        }
        
        var count:Int = 0
        
        for date in arrayByDate{
            count = 0
            
            for index in 0..<data.count
            {
                if (data[index])._fullTime == date as? String
                {
                    count += 1
                }
            }
            
            if count != 0
            {
                numberOfOrderInDate.append(count)
            }
        }
        
        count = 0
        
        var arr  = [TransacationRecord]()
        
        for order in numberOfOrderInDate
        {
            arr = [TransacationRecord]()
            
            for index in count..<order+count {
                
                arr.append(data[index])
                
            }
            
            totalData.append(arr)
            
            count += order
        }
        
        self.totalData = reverseData()
    }
    
    func reverseData() ->  [[TransacationRecord]] {
        
        var tempArray : [[TransacationRecord]] = []
        
        for index in stride(from: totalData.count-1, to: -1, by: -1) {
            tempArray.append(totalData[index])
        }
        
        return tempArray
    }
    
    func reverseDate() ->  [Int] {
        
        var tempArray : [Int] = []
        
        for index in stride(from: numberOfOrderInDate.count-1, to: -1, by: -1) {
            tempArray.append(numberOfOrderInDate[index])
        }
        
        return tempArray
    }
    
    func distributeInto2DArray() -> Void {
        
        var count = 0
        
        var arr  = [Double]()
        
        let range = reverseDate()
        
        for order in range
        {
            arr = [Double]()
            
            for index in count..<order+count {
                
                arr.append(cellsTotalMutableArray[index] as! Double)
                
            }
            
            cellsTotal.append(arr)
            
            count += order
        }
    }
    
    func cauculateTotalResults() -> Void {
        
        var range = reverseDate()
        var profit : Double = 0
        for index in 0..<range.count{
            for item in 0..<range[index]{
                if let record : TransacationRecord = self.totalData[index][item]{
                    for i in 0..<(record._productNames?.count)!{
                        if record._priceSellOut![i].isNumber && record._priceBuyIn![i].isNumber{
                            profit += record._priceSellOut![i].toDouble()! - record._priceBuyIn![i].toDouble()!
                        }
                    }
                    cellsTotalMutableArray.add(profit)
                    profit = 0
                    
                    //adding history of product's names into list
                    for index in 0..<(record._productNames?.count)!{
                        if !CommonUseClass._sharedManager.productList.contains(record._productNames![index]){
                            CommonUseClass._sharedManager.productList.insert(record._productNames![index])
                        }
                    }
                }
            }
        }
        
        print("list",CommonUseClass._sharedManager.productList)
        
        var tempTotal : Double = 0
        var index = 0
        var stack = 0
        
        for item in range{
            for _ in index..<self.cellsTotalMutableArray.count{
                tempTotal += cellsTotalMutableArray[index] as! Double
                
                if index + 1 == item+stack{
                    sectionTotal.add(tempTotal)
                    tempTotal = 0
                    stack += item
                    index += 1
                    break
                }
                index += 1
            }
        }
    }
}
