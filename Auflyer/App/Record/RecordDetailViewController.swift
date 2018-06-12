//
//  RecordDetailViewController.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/5.
//

import UIKit

class RecordDetailViewController: UIViewController, RecordDetailView {
    
    var presenter : RecordDetailViewPresenter!
    var record : TransacationRecord!
    var tableView : UITableView!
    var scrollView: UIScrollView!
    var container: UIView = UIView()
    var clientName: UILabel!
    var doneButton : UIButton!
    
    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Record Detail"
        
        self.presenter = RecordDetailViewPresenter(view: self)
        
    }
    
    func setNaviBar() -> Void {
        let rightAddButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        rightAddButton.setImage(UIImage(named: "AddClient"), for: .normal)
        rightAddButton.setTitleColor(UIColor.black, for: .normal)
        rightAddButton.addTarget(self, action: #selector(self.addRow), for: .touchUpInside)
        let rightwidthConstraint = rightAddButton.widthAnchor.constraint(equalToConstant: 40)
        let rightheightConstraint = rightAddButton.heightAnchor.constraint(equalToConstant: 40)
        rightheightConstraint.isActive = true
        rightwidthConstraint.isActive = true
        let navrightAddButton = UIBarButtonItem(customView: rightAddButton)
        
        let rightMinusButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        rightMinusButton.setImage(UIImage(named: "minus"), for: .normal)
        rightMinusButton.setTitleColor(UIColor.black, for: .normal)
        rightMinusButton.addTarget(self, action: #selector(self.deleteRow), for: .touchUpInside)
        let rightwidthMinusConstraint = rightMinusButton.widthAnchor.constraint(equalToConstant: 40)
        let rightheightMinusConstraint = rightMinusButton.heightAnchor.constraint(equalToConstant: 40)
        rightwidthMinusConstraint.isActive = true
        rightheightMinusConstraint.isActive = true
        let navrightMinusButton = UIBarButtonItem(customView: rightMinusButton)
        
        self.navigationItem.setRightBarButtonItems([navrightAddButton,navrightMinusButton], animated: true)
        
    }
    
    func jumpToSelectedRow(row : NSInteger) -> Void {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    @objc func addRow() -> Void {
        self.presenter.addRow()
    }
    
    @objc func deleteRow() -> Void {
        self.presenter.deleteRow()
    }
    
    @objc func save() -> Void {
        self.presenter.save()
    }
    
    func setHeader() -> Void {
        clientName = UILabel(frame: CGRect(x: screenWidth * 0.05, y: 15, width: screenWidth * 0.8, height: scrrenHeight * 0.1))
        clientName.font = UIFont.boldSystemFont(ofSize: 21)
        clientName.textAlignment = .left
        clientName.textColor = CommonUseClass._sharedManager.getMainColor()
        clientName.text = record._buyer?.toStringClientName()
        container.addSubview(clientName)
    }
    
    func setDoneBtn() -> Void {
        
        doneButton = UIButton(frame: CGRect(x: 0, y: tableView.frame.size.height + tableView.frame.origin.y, width: screenWidth, height: scrrenHeight * 0.08))
        doneButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 22))!
        doneButton.titleLabel?.textAlignment = .center
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.setTitle("Save", for: .normal)
        doneButton.layer.cornerRadius = 3.0
        doneButton.layer.masksToBounds = true
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        container.addSubview(doneButton)
        
    }
    
    func setScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: CGFloat(0), y: CGFloat(CommonUseClass._sharedManager.getNavigationBarHeight()), width: CGFloat(screenWidth), height: CGFloat(scrrenHeight - CommonUseClass._sharedManager.getNavigationBarHeight())))
        
        container = UIView(frame: CGRect(x: CGFloat(0), y: 0, width: CGFloat(screenWidth), height: 10000))
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(container)
    }
    
    func adjustScrollView() -> Void {
        
        container = UIView(frame: CGRect(x: CGFloat(0), y: 0, width: CGFloat(screenWidth), height: doneButton.frame.size.height+doneButton.frame.origin.y))
        
        self.scrollView.contentSize = CGSize(width: CGFloat(self.container.frame.size.width), height: CGFloat(self.container.frame.size.height))
    }
    
    func getRecord() -> TransacationRecord {
        return record
    }
    
    func getTableView() -> UITableView {
        return tableView
    }
    
    func getDoneBtn() -> UIButton {
        return doneButton
    }
    
    func getClientName() -> UILabel {
        return clientName
    }
    
    func getScrollView() -> UIScrollView {
        return scrollView
    }
    
    func scrollToBottom() -> Void {
        let bottomOffset = CGPoint(x: 0, y: (scrollView.contentSize.height) - (scrollView.bounds.size.height))
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
}
extension RecordDetailViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func setTable() {
        
        tableView = UITableView(frame: CGRect(x: CGFloat(screenWidth * 0.05), y:clientName.frame.size.height+clientName.frame.origin.y, width: CGFloat(screenWidth), height: CGFloat(scrrenHeight * 0.15 * CGFloat((record._productNames?.count)!+1))))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableHeaderView?.removeFromSuperview()
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.keyboardDismissMode = .onDrag
        container.addSubview(tableView)
        
        tableView.separatorStyle = .none
        
        let footer = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
        let propertyNib = UINib(nibName:"RecordDetailTableViewCell", bundle: Bundle(for: RecordDetailTableViewCell.self))
        tableView.register(propertyNib, forCellReuseIdentifier: "RecordDetailTableViewCell1")
        
        let nib = UINib(nibName:"TotalResultsTableViewCell", bundle: Bundle(for: TotalResultsTableViewCell.self))
        tableView.register(nib, forCellReuseIdentifier: "singleTotalResultsTableViewCell")
    }
    
    func createTotalCell() -> TotalResultsTableViewCell {
        
        let cell : TotalResultsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "singleTotalResultsTableViewCell") as! TotalResultsTableViewCell
        
        cell.selectionStyle = .none
        
        cell.setTotalPrice(self.presenter.totalBuyIn, self.presenter.totalSellOut, self.presenter.totalProfit)
        
        return cell
    }
    
    func updateTotalResults() -> Void {
        
        if let cell : TotalResultsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "singleTotalResultsTableViewCell") as? TotalResultsTableViewCell{
            cell.setTotalPrice(self.presenter.totalBuyIn, self.presenter.totalSellOut, self.presenter.totalProfit)
            let indexPath = IndexPath(item: (self.presenter.record._productNames?.count)!, section: 0)
            tableView.reloadRows(at: [indexPath], with: .top)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((record._productNames?.count)!+1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return scrrenHeight * 0.15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : RecordDetailTableViewCell!
        
        if indexPath.row == (record._productNames?.count)!{
            return createTotalCell()
        }
        
        if cell == nil{
            cell = self.tableView.dequeueReusableCell(withIdentifier: "RecordDetailTableViewCell1") as! RecordDetailTableViewCell
        }else{
            while(cell.contentView.subviews.last != nil){
                cell.contentView.subviews.last?.removeFromSuperview()
            }
        }
        
        cell.indexTag = indexPath.row
        
        cell.calculateTotalBlock = { buyIn, sellOut, profit, indexTag in
            print(indexTag)
            self.presenter.totalBuyInArray[indexTag] = buyIn
            self.presenter.totalSellOutArray[indexTag] = sellOut
            self.presenter.totalProfitArray[indexTag] = profit
            
            self.presenter.calculateTotal()
            
            self.updateTotalResults()
            
            self.jumpToSelectedRow(row: indexTag)
        }
                
        cell.bindData(record: record, indexPath : indexPath)
        
        cell.selectionStyle = .none
        
        cell.findMatchBlock = { keyword in
            
            var searchResult : [String] = []
            for item in CommonUseClass._sharedManager.productList{
                if item.range(of:keyword, options: .caseInsensitive) != nil {
                    searchResult.append(item)
                }
            }
            return searchResult.sorted()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == (record._productNames?.count)!{
            return
        }
        
        let cell = self.tableView.cellForRow(at: indexPath) as! RecordDetailTableViewCell
        
        if (cell.accessoryType == .checkmark ) {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
            cell.accessoryButton = cell.subviews.compactMap { $0 as? UIButton }.first
        }
    }
}


