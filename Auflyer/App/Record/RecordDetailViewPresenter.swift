//
//  RecordDetailViewPresenter.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/5.
//

import UIKit

protocol RecordDetailView: class {
    func setScrollView()
    func setTable()
    func adjustScrollView()
    func getRecord() -> TransacationRecord
    func setDoneBtn()
    func setHeader()
    func getTableView() -> UITableView
    func getClientName() -> UILabel
    func setNaviBar()
    func getDoneBtn() -> UIButton
    func scrollToBottom()
    func getScrollView() -> UIScrollView
}

class RecordDetailViewPresenter {
    
    var recordDetailView : RecordDetailView?
    
    var record : TransacationRecord!
    
    //MARK: - TotalData
    var totalBuyInArray = [Double](repeating: 0, count: 5000)
    var totalSellOutArray =  [Double](repeating: 0, count: 5000)
    var totalProfitArray =  [Double](repeating: 0, count: 5000)
    var totalBuyIn : Double = 0
    var totalSellOut : Double = 0
    var totalProfit : Double = 0
    
    required init(view: RecordDetailView) {
        
        recordDetailView = view
        
        self.record = recordDetailView?.getRecord()
        
        recordDetailView?.setNaviBar()
        
        self.Initialise()
    }
    
    func calculateTotal() -> Void {
        
        totalBuyIn = 0
        totalSellOut = 0
        totalProfit = 0
        
        for item in totalBuyInArray{
            totalBuyIn += item
        }
        for item in totalSellOutArray{
            totalSellOut += item
        }        
        for item in totalProfitArray{
            totalProfit += item
        }
        
    }
    
    func Initialise() -> Void {
        
        recordDetailView?.setScrollView()
        
        recordDetailView?.setHeader()
        
        recordDetailView?.setTable()
        
        recordDetailView?.setDoneBtn()
        
        recordDetailView?.adjustScrollView()
    }
    
    func reInitialiseView() -> Void {
        
        recordDetailView?.getScrollView().removeFromSuperview()
        
        recordDetailView?.getTableView().removeFromSuperview()
        
        recordDetailView?.getDoneBtn().removeFromSuperview()
        
        recordDetailView?.getClientName().removeFromSuperview()
        
        self.Initialise()
    }
    
    @objc func addRow() -> Void {
        
        self.record._productNames?.append("")
        self.record._priceBuyIn?.append("")
        self.record._priceSellOut?.append("")
        
        reInitialiseView()
        
        if (self.record._productNames?.count)! >= 5{
            recordDetailView?.scrollToBottom()
        }
    }
    
    func save() -> Void{ 
        let cells = CommonUseClass._sharedManager.getAllCells(tableView: (recordDetailView?.getTableView())!)
        
        var _priceBuyIn: [String] = []
        var _priceSellOut: [String] = []
        var _productNames: [String] = []
        
        for item in cells{
            let cell = item as! RecordDetailTableViewCell
            
            if !(cell.productName.text?.isEmpty)!{
                _productNames.append(cell.productName.text!)
            }
            else{
                _productNames.append("Unfilled")
            }
            
            if !(cell.priceIn.text?.isEmpty)!{
                _priceBuyIn.append(cell.priceIn.text!)
            }
            else{
                _priceBuyIn.append("Unfilled")
            }
            
            if !(cell.priceOut.text?.isEmpty)!{
                _priceSellOut.append(cell.priceOut.text!)
            }
            else{
                _priceSellOut.append("Unfilled")
            }
        }
        
        self.record._priceBuyIn = _priceBuyIn
        self.record._priceSellOut = _priceSellOut
        self.record._productNames = _productNames
        
        DynamoDBManager._sharedManager.saveData(model: self.record){
            CommonUseClass._sharedManager.sendAlert(msg: "Save Sucessful", view: self.recordDetailView as! UIViewController)
        }
    }
    
    func deleteRow() -> Void{
        
        self.totalBuyInArray = [Double](repeating: 0, count: 5000)
        self.totalSellOutArray =  [Double](repeating: 0, count: 5000)
        self.totalProfitArray =  [Double](repeating: 0, count: 500)
        
        let allTableCells = CommonUseClass._sharedManager.getAllCells(tableView: (recordDetailView?.getTableView())!)
        let cells : NSMutableArray = NSMutableArray()
        
        for cell in allTableCells{
            if let cell : RecordDetailTableViewCell = cell as? RecordDetailTableViewCell{
                if cell.accessoryType == .checkmark{
                    cells.add(cell)
                }
            }
        }
        
        for index in stride(from: cells.count-1, to: -1, by: -1) {
            
            let index = ((cells[index] as? RecordDetailTableViewCell)?.indexTag)!
            
            self.record._priceBuyIn?.remove(at: index)
            self.record._priceSellOut?.remove(at: index)
            self.record._productNames?.remove(at: index)
            
        }
        
        self.calculateTotal()
        
        reInitialiseView()
    }
    
}
