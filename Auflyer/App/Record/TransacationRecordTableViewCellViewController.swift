//
//  TransacationRecordViewController.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/30.
//

import UIKit
import Bond
import SkyFloatingLabelTextField
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import AWSS3
import Photos
import NVActivityIndicatorView

class TransacationRecordViewController: UIViewController, TransacationRecordView {
    
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    
    var presenter : TransacationRecordViewPresenter!
    
    var tableView : UITableView!
    
    let foldSwitch : NSMutableArray = NSMutableArray()
    
    let cellArray : NSMutableArray = NSMutableArray()
    
    var spining :  NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Record"
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.presenter = TransacationRecordViewPresenter(view: self)
        
        self.setNavigationBtn()
        
    }
    
    func makeData(){
        if self.presenter.totalData.count == 0{
            return
        }
        for _ : NSInteger in 0...self.presenter.totalData.count-1 {
            foldSwitch.add(false)
        }
    }
    
    func setNavigationBtn() -> Void {
        
        let leftButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        leftButton.setImage(UIImage(named: "refresh"), for: .normal)
        leftButton.setTitleColor(UIColor.black, for: .normal)
        leftButton.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        let widthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = leftButton.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        let navLeftButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = navLeftButton;
        
        let rightButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        rightButton.setImage(UIImage(named: "AddClient"), for: .normal)
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.addTarget(self, action: #selector(self.addClient), for: .touchUpInside)
        let rightwidthConstraint = rightButton.widthAnchor.constraint(equalToConstant: 40)
        let rightheightConstraint = rightButton.heightAnchor.constraint(equalToConstant: 40)
        rightheightConstraint.isActive = true
        rightwidthConstraint.isActive = true
        let navRightButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = navRightButton;
    }
    
    func examineDate(record : TransacationRecord) -> String {
        let date = record._date?.convertToNSDateFromString()
        if NSCalendar.current.isDateInToday(date!) == true {
            return "Today"
        }else if NSCalendar.current.isDateInYesterday(date!) == true{
            return "Yesterday"
        }else if NSCalendar.current.isDateInTomorrow(date!) == true{
            return "Tomorrow"
        }else{
            return record._fullTime!
        }
    }
    
    func getTable() -> UITableView {
        return tableView
    }
    
    @objc func refresh() -> Void {
        
        self.presenter.refresh()
    }
    
    @objc func addClient() -> Void {
        
        self.presenter.addClient()
    }
}
extension TransacationRecordViewController : UITableViewDelegate,UITableViewDataSource {
    
    func setTable() {
        
        tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.isScrollEnabled = true
        
        let naviBarHeight = CommonUseClass._sharedManager.getNavigationBarHeight()
        
        var tabBarHeight : CGFloat = 0
        
        if var tabBarHeight = self.tabBarController?.tabBar.frame.height{
            tabBarHeight = (self.tabBarController?.tabBar.frame.height)!
        }else{
            tabBarHeight = 49
        }
        
        tableView.frame = CGRect(x: CGFloat(0), y: CGFloat(naviBarHeight), width: CGFloat(self.view.frame.size.width), height: CGFloat(self.view.frame.size.height-naviBarHeight-tabBarHeight-15))
        
        tableView.keyboardDismissMode = .onDrag
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.presenter.deleteItemInServer(indexPath : indexPath)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.presenter.totalData.count != 0{
            return self.presenter.totalData.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if foldSwitch[section] as! Bool{
            return self.presenter.totalData[section].count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : TransacationRecordSectionHeader = TransacationRecordSectionHeader()
        view.tag = section
        view.foldButton.isSelected = foldSwitch[section] as! Bool
        view.spreadBlock = {(index : NSInteger,isSelected : Bool) in
            let ratio : NSInteger = index
            if self.foldSwitch[ratio] as! Bool{
                self.foldSwitch[ratio] = false
            }else{
                self.foldSwitch[ratio] = true
            }
            self.tableView.reloadSections(IndexSet.init(integer: index), with: UITableViewRowAnimation.automatic)
        }
        let record = self.presenter.totalData[section][0]
        
        view.titleLabel.text = examineDate(record : record)
        view.totalEarned.text = (self.presenter.sectionTotal[section] as? Double)?.toStringWithTotal()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell\(indexPath.section)\(indexPath.row)"
        self.tableView.register(UINib.init(nibName: "TransacationRecordTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let cell : TransacationRecordTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TransacationRecordTableViewCell
        
        cell.ClientName.text = self.presenter.totalData[indexPath.section][indexPath.row]._buyer
        cell.totalEarned.text = (self.presenter.cellsTotal[indexPath.section][indexPath.row]).toStringWithTotal()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetail", sender: self.presenter.totalData[indexPath.section][indexPath.row])
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toDetail") {
            let nextView: RecordDetailViewController? = segue.destination as? RecordDetailViewController
            nextView?.record = sender! as! TransacationRecord
        }
    }
}
extension TransacationRecordViewController{
    
    func startAnimating(type : Int) -> Void {
        spining = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100), type:NVActivityIndicatorType(rawValue: type), color:CommonUseClass._sharedManager.getMainColor())
        spining.startAnimating()
        self.view.addSubview(spining)
    }
    
    func stopAnimating() -> Void {
        spining.stopAnimating()
        spining.removeFromSuperview()
    }
}
