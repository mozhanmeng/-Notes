//
//  CollectUserInfoViewController.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/11/17.
//  Copyright © 2017年 YingyongZheng. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import NVActivityIndicatorView
import Bond
class ContactViewController: UIViewController, ContactView {

    lazy var dynamicAnimator = UIDynamicAnimator()
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    var tableView : UITableView!
    var titleTextField : UITextField!
    var editView : UIView!
    var searchBar : UISearchBar!
    var searchResult : NSMutableArray = NSMutableArray()
    var processing = false
    var presenter : ContactViewPresenter!
    var spining :  NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact List"
        self.presenter = ContactViewPresenter(view: self)
    }
    
    func setTabBarIconAndTitle() -> Void {

        self.tabBarController?.tabBar.items![0].image = UIImage(named: "contact")?.withRenderingMode(.alwaysTemplate)
        self.tabBarController?.tabBar.items![1].image = UIImage(named: "upload")?.withRenderingMode(.alwaysTemplate)
        self.tabBarController?.tabBar.items![2].image = UIImage(named: "record")?.withRenderingMode(.alwaysTemplate)

        self.tabBarController?.tabBar.items?[0].title = NSLocalizedString("Client", comment: "comment")
        self.tabBarController?.tabBar.items?[1].title = NSLocalizedString("Upload ID", comment: "comment")
        self.tabBarController?.tabBar.items?[2].title = NSLocalizedString("Record", comment: "comment")

    }
    
    func setLeftNavigationBtn() -> Void {
        
        let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(30)))
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        button.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 13))!
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1.0
        button.layer.backgroundColor = UIColor.lightGray.cgColor
        button.layer.borderColor = UIColor.lightGray.cgColor
        let navButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = navButton
        
    }
    
    @objc func logout() -> Void {
        if (AWSSignInManager.sharedInstance().isLoggedIn) && processing == false {
            processing = true
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                self.performSegue(withIdentifier: "toInitial", sender: nil)
                self.processing = false
            })
        }
    }
    
    func setNavigationBtn() -> Void {
        
        let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        button.setImage(UIImage(named: "AddClient"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(drawFillMainMobile), for: .touchUpInside)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        let navButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = navButton;
    }
    
    @objc func drawFillMainMobile() -> Void {
        
        if editView != nil{
            editView.removeFromSuperview()
        }
        
        editView = UIView(frame: CGRect(x: screenWidth * 0.1, y: 0, width: screenWidth * 0.8, height: scrrenHeight * 0.5))
        editView.backgroundColor = CommonUseClass._sharedManager.getMainColor()
        editView.layer.cornerRadius = 4
        view.addSubview(editView)
        
        let titleLabel = UILabel(frame: CGRect(x: editView.frame.size.width * 0.1, y: 0, width: editView.frame.size.width * 0.8, height: self.scrrenHeight * 0.2))
        titleLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(screenWidth * 0.05))
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.numberOfLines = 5
        titleLabel.textColor = .white
        titleLabel.text = "Please enter the client's name which cannot be changed once it is set up"
        editView.addSubview(titleLabel)
        
        titleTextField = UITextField(frame: CGRect(x:editView.frame.size.width * 0.05 ,y: editView.frame.size.height * 0.45,width: editView.frame.size.width * 0.9,height: 40))
        titleTextField.font = UIFont.systemFont(ofSize:15)
        titleTextField.attributedPlaceholder = NSAttributedString(string:"Please fill in the client's name", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.white])
        titleTextField.layer.borderColor = UIColor.white.cgColor
        titleTextField.layer.borderWidth = 2
        titleTextField.textColor = .white
        titleTextField.layer.cornerRadius = 4.0
        titleTextField.returnKeyType = UIReturnKeyType.done
        titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        editView.addSubview(titleTextField)
        
        let doneButton = UIButton(frame: CGRect(x: editView.frame.size.width * 0.15, y: editView.frame.size.height * 0.75, width: editView.frame.size.width * 0.25, height: editView.frame.size.height * 0.08))
        doneButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 14))!
        doneButton.titleLabel?.textAlignment = .center
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.setTitle("Confirm", for: .normal)
        doneButton.layer.cornerRadius = 3.0
        doneButton.layer.masksToBounds = true
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.addTarget(self, action: #selector(self.checkDuiplicate), for: .touchUpInside)
        editView.addSubview(doneButton)
        
        let cancelButton = UIButton(frame: CGRect(x: editView.frame.size.width * 0.6, y: editView.frame.size.height * 0.75, width: editView.frame.size.width * 0.25, height: editView.frame.size.height * 0.08))
        cancelButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 14))!
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 3.0
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        cancelButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        cancelButton.addTarget(self, action: #selector(removeEditView), for: .touchUpInside)
        editView.addSubview(cancelButton)
        
        createAnimator()
        
    }
    
    @objc func removeEditView() -> Void{
        if editView != nil{
            editView.removeFromSuperview()
        }
    }
    
    func reloadTableview() -> Void{
        self.tableView.reloadData()
    }
    
    func pushToDetail(client : Client) -> Void {
        self.performSegue(withIdentifier: "toDetail", sender: client)
    }
    
    @objc func returnTitleTextfiledText() -> String {
        return (titleTextField.text)!
    }
    
    @objc func returnSearchResult() -> NSMutableArray {
        return searchResult
    }
    
    func startAnimating(type : Int) -> Void {
        spining = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100), type:NVActivityIndicatorType(rawValue: type), color:CommonUseClass._sharedManager.getMainColor())
        spining.startAnimating()
        self.view.addSubview(spining)
    }
    
    func stopAnimating() -> Void {
        spining.stopAnimating()
        spining.removeFromSuperview()
    }
    
    @objc func checkDuiplicate() -> Void {
        for item in self.presenter.data{
            let client = item as! Client
            if client._fullname == titleTextField.text!{
                CommonUseClass._sharedManager.sendAlert(msg: "This user name exists", view: self)
                return
            }
        }
        self.presenter.pushAddClients()
    }
}
//MARK: - Set tabbleview
extension ContactViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func setTable() {

        let naviBarHeight = CommonUseClass._sharedManager.getNavigationBarHeight()
        
        var tabBarHeight : CGFloat = 0
                
        if var tabBarHeight = self.tabBarController?.tabBar.frame.height{
            tabBarHeight = (self.tabBarController?.tabBar.frame.height)!
        }else{
            tabBarHeight = 49
        }
        
        tableView = UITableView()
        
        tableView.frame = CGRect(x: CGFloat(0), y: CGFloat(naviBarHeight), width: CGFloat(self.view.frame.size.width), height: CGFloat(self.view.frame.size.height-tabBarHeight-15))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        automaticallyAdjustsScrollViewInsets = true
        
        DispatchQueue.main.async {
            
            self.tableView.setContentOffset(CGPoint(x: CGFloat(0), y: CGFloat(44)), animated: true)
            
        }
        
        tableView.keyboardDismissMode = .onDrag
        self.view.addSubview(tableView)
        
        let propertyNib = UINib(nibName:"ContatViewTableViewCell", bundle: Bundle(for: ContatViewTableViewCell.self))
        tableView.register(propertyNib, forCellReuseIdentifier: "ContatViewTableViewCell1")
        
        let footer = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.presenter.deleteItemInServer(indexPath : indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar != nil && searchResult.count == 0 && !(searchBar.text!.isEmpty)
        {
            return 0
        }
        else if searchResult.count != 0
        {
            return searchResult.count
        }
        else
        {
            return self.presenter.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return scrrenHeight * 0.08
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ContatViewTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ContatViewTableViewCell1") as! ContatViewTableViewCell
        
        cell.selectionStyle = .none
        
        if(searchResult.count != 0)
        {
            cell.setData(client: searchResult[indexPath.row] as! Client)
        }
        else
        {
            cell.setData(client: self.presenter.data[indexPath.row] as! Client)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searchResult.count != 0)
        {
            performSegue(withIdentifier: "toDetail", sender: searchResult[indexPath.row])
        }
        else
        {
        performSegue(withIdentifier: "toDetail", sender: self.presenter.data[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toDetail") {
            let nextView: ClientDetailViewController? = segue.destination as? ClientDetailViewController
            nextView?.renewData = self.presenter as renewDataDelegate
            nextView?.client = sender as! Client
        }
    }
}
//MARK: - Set Search Bar
extension ContactViewController :  UISearchBarDelegate
{
    func createSearchBar() -> Void {
        searchBar = UISearchBar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(screenWidth), height: CGFloat(44)))
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        tableView.tableHeaderView = searchBar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchResult.removeAllObjects()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("[ViewController searchBar] searchText: \(searchText)")
        
        searchResult = NSMutableArray()
        
        for index in 0...self.presenter.data.count-1 {
            
            let client = self.presenter.data[index] as! Client
            
            if client._userId!.lowercased().contains(searchText.lowercased())
                || client._fullname!.lowercased().contains(searchText.lowercased())
            {
                searchResult.add(client)
            }
            
            for item in client._mobile!{
                if item.lowercased().contains(searchText.lowercased()){
                    searchResult.add(client)
                }
            }
            
            for item in client._address!{
                if item.lowercased().contains(searchText.lowercased()){
                    searchResult.add(client)
                }
            }
            
            for item in client._chineseIDNumber!{
                if item.lowercased().contains(searchText.lowercased()){
                    searchResult.add(client)
                }
            }
        }
        
        self.presenter.removeDupilicatedContact()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
//MARK: - dynamicAnimator
    func createAnimator() -> Void {
        
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        //创建并添加重力行为
        let gravityBehavior = UIGravityBehavior(items: [editView])
        dynamicAnimator.addBehavior(gravityBehavior)
        gravityBehavior.magnitude = 3
        
        
        //创建并添加碰撞行为
        let collisionBehavior = UICollisionBehavior(items: [editView])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.addBoundary(withIdentifier: "1" as NSCopying, from: CGPoint(x: 0, y: scrrenHeight * 0.745), to:  CGPoint(x: screenWidth, y: scrrenHeight * 0.745))
        dynamicAnimator.addBehavior(collisionBehavior)
        
        let bounce = UIDynamicItemBehavior(items:[editView])
        bounce.elasticity = 0.5
        dynamicAnimator.addBehavior(bounce)
    }
}
