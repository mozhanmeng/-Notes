//
//  ClientDetailViewController.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/11/29.
//

import UIKit
import SkyFloatingLabelTextField
import DropDown
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import AWSS3
import SVProgressHUD
import Photos
import NVActivityIndicatorView

//MARK: - Enum
public enum UIImagePickerControllerSourceType : Int {
    case photoLibrary
    case camera
    case savedPhotosAlbum
}


//MARK: - delegate
protocol refreshFieldDelegate {
    func setSaveField(data: NSMutableArray, selectedField : String)
}

class ClientDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,refreshFieldDelegate, UITextFieldDelegate, ClientView {
    
    //MARK: - Atrributes
    var fullNameField : SkyFloatingLabelTextField!
    var lastNameField : SkyFloatingLabelTextField!
    var mobileField : SkyFloatingLabelTextField!
    var emailField : SkyFloatingLabelTextField!
    var addressField : SkyFloatingLabelTextField!
    var ChineseNumberField : SkyFloatingLabelTextField!
    
    //MARK: - UI Atrributes
    var container : UIView!
    var screenScrollview : UIScrollView!
    var IDBeingChanged : Int!
    var tableView : UITableView!
    var doneButton : UIButton!
    
    //MARK: - Funtional Atrributes
    var presenter : ClientDetailViewPresenter!
    var client : Client = Client()
    var dropDown = DropDown()
    var dropDownAddress = DropDown()
    var dropDownChineseNumber = DropDown()
    let imagePicker = UIImagePickerController()
    var delegate : refreshFieldDelegate!
    var renewData : renewDataDelegate!
    var info1 : [String : Any]!
    var info2 : [String : Any]!
    
    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ClientDetailViewPresenter(view: self)
        setUI()
        bindInfo()
        setImage()
    }
    
    //MARK: - SetUI
    func setUI() -> Void {
        
        screenScrollview = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: scrrenHeight))
        screenScrollview.layer.cornerRadius = 4
        screenScrollview.backgroundColor = UIColor.clear
        screenScrollview.showsVerticalScrollIndicator = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(screenScrollview)
        
        screenScrollview.contentInset = UIEdgeInsets.zero
        screenScrollview.scrollIndicatorInsets = UIEdgeInsets.zero
        screenScrollview.contentOffset = CGPoint(x: 0.0, y: 0.0)
        
        container = UIView(frame: CGRect(x: 0, y: 0, width: screenScrollview.frame.size.width, height: screenScrollview.frame.size.height))
        screenScrollview.addSubview(container)
        
        self.title = client._fullname
        
        fullNameField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.05, width:screenWidth * 0.8, height:scrrenHeight * 0.08))
        fullNameField.placeholder = "Full Name"
        fullNameField.title = "Full Name"
        
        fullNameField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        fullNameField.textColor = CommonUseClass._sharedManager.getMainColor()
        fullNameField.lineColor = CommonUseClass._sharedManager.getMainColor()
        fullNameField.delegate = self as UITextFieldDelegate
        fullNameField.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        fullNameField.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        fullNameField.isUserInteractionEnabled = false
        fullNameField.lineHeight = 1.0 // bottom line height in points
        fullNameField.selectedLineHeight = 2.0
        container.addSubview(fullNameField)
        
        let fullNameCopyBtn = UIImageView()
        fullNameCopyBtn.frame = CGRect(x:fullNameField.frame.size.width + fullNameField.frame.origin.x - 35, y:scrrenHeight * 0.05 + 15, width:screenWidth * 0.1, height:screenWidth * 0.1)
        fullNameCopyBtn.image = UIImage(named: "copy")!
        fullNameCopyBtn.isUserInteractionEnabled = true
        fullNameCopyBtn.tag = 2001
        let firstNameTap = UITapGestureRecognizer(target: self, action: #selector(copyTestField(_:)))
        fullNameCopyBtn.addGestureRecognizer(firstNameTap)
        container.addSubview(fullNameCopyBtn)
        
        mobileField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.15, width:screenWidth * 0.8, height:scrrenHeight * 0.08)
        )
        mobileField.placeholder = "Mobile Phone Number"
        mobileField.title = "Mobile Phone Number"
        mobileField.isUserInteractionEnabled = false
        mobileField.delegate = self as UITextFieldDelegate
        mobileField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        mobileField.textColor = CommonUseClass._sharedManager.getMainColor()
        mobileField.lineColor = CommonUseClass._sharedManager.getMainColor()
        mobileField.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        mobileField.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        
        mobileField.lineHeight = 1.0 // bottom line height in points
        mobileField.selectedLineHeight = 2.0
        container.addSubview(mobileField)
        
        let editMobile = UIButton()
        editMobile.frame = CGRect(x:mobileField.frame.origin.x + mobileField.frame.size.width * 0.55, y:mobileField.frame.origin.y+mobileField.frame.size.height - 60, width:45, height:25)
        editMobile.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 10))!
        editMobile.titleLabel?.textAlignment = .center
        editMobile.setTitleColor(UIColor.white, for: .normal)
        editMobile.setTitle("Edit",for: .normal)
        editMobile.layer.cornerRadius = 3.0
        editMobile.tag = -3
        editMobile.layer.masksToBounds = true
        editMobile.layer.borderWidth = 1.0
        editMobile.layer.backgroundColor = UIColor.lightGray.cgColor
        editMobile.layer.borderColor = UIColor.lightGray.cgColor
        editMobile.addTarget(self, action: #selector(self.pushToEdit(_:)), for: .touchUpInside)
        container.addSubview(editMobile)
        
        let mobileCopyBtn = UIImageView()
        mobileCopyBtn.frame = CGRect(x:mobileField.frame.size.width + mobileField.frame.origin.x - 35, y:mobileField.frame.origin.y + mobileField.frame.size.height - 39, width:screenWidth * 0.1, height:screenWidth * 0.1)
        mobileCopyBtn.tag = 2002
        mobileCopyBtn.image = UIImage(named: "copy")!
        let mobileCopyTap = UITapGestureRecognizer(target: self, action: #selector(copyTestField(_:)))
        mobileCopyBtn.addGestureRecognizer(mobileCopyTap)
        mobileCopyBtn.isUserInteractionEnabled = true
        container.addSubview(mobileCopyBtn)
        
        let moreMobileButton  = UIButton(type: .custom)
        moreMobileButton.frame = CGRect(x:screenWidth * 0.85, y:mobileField.frame.origin.y+mobileField.frame.size.height - 20, width:30, height:30)
        moreMobileButton.setImage(UIImage(named: "down"), for: .normal)
        moreMobileButton.addTarget(self, action: #selector(showMobileList), for: .touchUpInside)
        container.addSubview(moreMobileButton)
        
        let dropDownView = UIView(frame: CGRect(x:screenWidth * 0.05, y:mobileField.frame.origin.y+mobileField.frame.size.height+10, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        container.addSubview(dropDownView)
        
        dropDown = DropDown()
        dropDown.anchorView = dropDownView // UIView or UIBarButtonItem
        dropDown.width = screenWidth * 0.9
        
        dropDown.dataSource = client._mobile!
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            UIPasteboard.general.string = item
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)
            
        }
        
        addressField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.25, width:screenWidth * 0.8, height:scrrenHeight * 0.08))
        addressField.placeholder = "Address"
        addressField.title = "Address"
        addressField.isUserInteractionEnabled = false
        addressField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        addressField.textColor = CommonUseClass._sharedManager.getMainColor()
        addressField.delegate = self as UITextFieldDelegate
        addressField.lineColor = CommonUseClass._sharedManager.getMainColor()
        addressField.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        addressField.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        
        addressField.lineHeight = 1.0 // bottom line height in points
        addressField.selectedLineHeight = 2.0
        container.addSubview(addressField)
        
        let editAdress = UIButton()
        editAdress.frame = CGRect(x:addressField.frame.origin.x + addressField.frame.size.width * 0.26, y:addressField.frame.origin.y+addressField.frame.size.height - 60, width:45, height:25)
        editAdress.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 10))!
        editAdress.titleLabel?.textAlignment = .center
        editAdress.setTitleColor(UIColor.white, for: .normal)
        editAdress.setTitle("Edit",for: .normal)
        editAdress.layer.cornerRadius = 3.0
        editAdress.tag = -4
        editAdress.layer.masksToBounds = true
        editAdress.layer.borderWidth = 1.0
        editAdress.layer.backgroundColor = UIColor.lightGray.cgColor
        editAdress.layer.borderColor = UIColor.lightGray.cgColor
        editAdress.addTarget(self, action: #selector(self.pushToEdit(_:)), for: .touchUpInside)
        container.addSubview(editAdress)
        
        let addressCopyBtn = UIImageView()
        addressCopyBtn.frame = CGRect(x:addressField.frame.size.width + addressField.frame.origin.x - 35, y:addressField.frame.origin.y + addressField.frame.size.height - 39, width:screenWidth * 0.1, height:screenWidth * 0.1)
        addressCopyBtn.tag = 2003
        addressCopyBtn.image = UIImage(named: "copy")!
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(copyTestField(_:)))
        addressCopyBtn.addGestureRecognizer(addressTap)
        addressCopyBtn.isUserInteractionEnabled = true
        container.addSubview(addressCopyBtn)
        
        let moreAddressButton  = UIButton(type: .custom)
        moreAddressButton.frame = CGRect(x:screenWidth * 0.85, y:addressField.frame.origin.y+addressField.frame.size.height - 20, width:30, height:30)
        moreAddressButton.setImage(UIImage(named: "down"), for: .normal)
        moreAddressButton.addTarget(self, action: #selector(showAddressList), for: .touchUpInside)
        container.addSubview(moreAddressButton)
        
        let dropDownAddressView = UIView(frame: CGRect(x:screenWidth * 0.05, y:addressField.frame.origin.y+addressField.frame.size.height+10, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        container.addSubview(dropDownAddressView)
        
        dropDownAddress = DropDown()
        dropDownAddress.anchorView = dropDownAddressView // UIView or UIBarButtonItem
        dropDownAddress.width = screenWidth * 0.9
        
        dropDownAddress.dataSource = client._address!
        
        dropDownAddress.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            UIPasteboard.general.string = item
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)
            
        }
        
        
        
        ChineseNumberField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.35, width:screenWidth * 0.8, height:scrrenHeight * 0.08))
        ChineseNumberField.placeholder = "Chinese ID"
        ChineseNumberField.title = "Chinese ID"
        ChineseNumberField.isUserInteractionEnabled = false
        ChineseNumberField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        ChineseNumberField.textColor = CommonUseClass._sharedManager.getMainColor()
        ChineseNumberField.delegate = self as UITextFieldDelegate
        ChineseNumberField.lineColor = CommonUseClass._sharedManager.getMainColor()
        ChineseNumberField.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        ChineseNumberField.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        
        ChineseNumberField.lineHeight = 1.0 // bottom line height in points
        ChineseNumberField.selectedLineHeight = 2.0
        container.addSubview(ChineseNumberField)
        
        let editChineseID = UIButton()
        editChineseID.frame = CGRect(x:ChineseNumberField.frame.origin.x + ChineseNumberField.frame.size.width * 0.26, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height - 60, width:45, height:25)
        editChineseID.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 10))!
        editChineseID.titleLabel?.textAlignment = .center
        editChineseID.setTitleColor(UIColor.white, for: .normal)
        editChineseID.setTitle("Edit",for: .normal)
        editChineseID.layer.cornerRadius = 3.0
        editChineseID.tag = -5
        editChineseID.layer.masksToBounds = true
        editChineseID.layer.borderWidth = 1.0
        editChineseID.layer.backgroundColor = UIColor.lightGray.cgColor
        editChineseID.layer.borderColor = UIColor.lightGray.cgColor
        editChineseID.addTarget(self, action: #selector(self.pushToEdit(_:)), for: .touchUpInside)
        container.addSubview(editChineseID)
        
        let ChineseNumberCopyBtn = UIImageView()
        ChineseNumberCopyBtn.frame = CGRect(x:ChineseNumberField.frame.size.width + ChineseNumberField.frame.origin.x - 35, y:ChineseNumberField.frame.origin.y + ChineseNumberField.frame.size.height - 39, width:screenWidth * 0.1, height:screenWidth * 0.1)
        ChineseNumberCopyBtn.tag = 2004
        ChineseNumberCopyBtn.image = UIImage(named: "copy")!
        ChineseNumberCopyBtn.isUserInteractionEnabled = true
        let ChineseNumberTap = UITapGestureRecognizer(target: self, action: #selector(copyTestField(_:)))
        ChineseNumberCopyBtn.addGestureRecognizer(ChineseNumberTap)
        container.addSubview(ChineseNumberCopyBtn)
        
        let moreChineseButton  = UIButton(type: .custom)
        moreChineseButton.frame = CGRect(x:screenWidth * 0.85, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height - 20, width:30, height:30)
        moreChineseButton.setImage(UIImage(named: "down"), for: .normal)
        moreChineseButton.addTarget(self, action: #selector(showChineseList), for: .touchUpInside)
        container.addSubview(moreChineseButton)
        
        let dropDownChineseView = UIView(frame: CGRect(x:screenWidth * 0.05, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height+10, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        container.addSubview(dropDownChineseView)
        
        dropDownChineseNumber = DropDown()
        dropDownChineseNumber.anchorView = dropDownChineseView // UIView or UIBarButtonItem
        dropDownChineseNumber.width = screenWidth * 0.9
        
        dropDownChineseNumber.dataSource = client._chineseIDNumber!
        
        dropDownChineseNumber.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            UIPasteboard.general.string = item
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)
            
        }
        
        setTable()
        tableView.frame = CGRect(x:screenWidth * 0.05, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height+10, width:screenWidth * 0.9, height:self.presenter.calculateHeightofTable())
        finalUIInitilise()
    }
    
    @objc func pushToEdit(_ sender: UIButton) -> Void {
        switch (sender.tag)
        {
        case -3:
            self.performSegue(withIdentifier: "toEdit", sender:  self.client._mobile!)
        case -4:
            self.performSegue(withIdentifier: "toEdit", sender:  self.client._address!)
        case -5:
            self.performSegue(withIdentifier: "toEdit", sender:  self.client._chineseIDNumber!)
        default:
            break
        }
    }
    
    func finalUIInitilise() -> Void {
        
        if doneButton != nil{
            doneButton.removeFromSuperview()
        }
        
        doneButton = UIButton(frame: CGRect(x: 0, y:  tableView.frame.size.height + tableView.frame.origin.y + 15, width: screenWidth, height: scrrenHeight * 0.08))
        doneButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 14))!
        doneButton.titleLabel?.textAlignment = .center
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.setTitle("Save", for: .normal)
        doneButton.layer.cornerRadius = 3.0
        doneButton.layer.masksToBounds = true
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        doneButton.addTarget(self, action: #selector(chooseURLToUpload), for: .touchUpInside)
        container.addSubview(doneButton)
        
        container.frame.size.height = doneButton.frame.size.height + doneButton.frame.origin.y
        screenScrollview.contentSize = CGSize(width: CGFloat(container.frame.size.width), height: CGFloat(container.frame.size.height))
    }
    
    //MARK: - ChineseID Management
    func setImage() -> Void {
        
        var indexPath = IndexPath(row: 0, section: 0)
        
        var cell:ChineseIDTableViewCell = tableView.cellForRow(at: indexPath) as! ChineseIDTableViewCell
        
        let spining = NVActivityIndicatorView(frame: CGRect(x: cell.frame.width/2-50, y: cell.frame.height/2-50, width: 100, height: 100), type:NVActivityIndicatorType(rawValue: 26), color:UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0))
        if self.client._coverName != nil && indexPath.row == 0{
            cell.ID.image = UIImage(named: "blank")!
            spining.startAnimating()
            cell.addSubview(spining)
            downloadImageFromS3(imageKey: client._coverName!, target: cell.ID){
                self.tableView.reloadData()
                self.tableView.frame = CGRect(x:self.self.screenWidth * 0.05, y:self.ChineseNumberField.frame.origin.y+self.ChineseNumberField.frame.size.height+10, width:self.screenWidth * 0.9, height:self.presenter.calculateHeightofTable())
                self.finalUIInitilise()
                spining.stopAnimating()
                spining.removeFromSuperview()
            }
        }
        
        indexPath = IndexPath(row: 1, section: 0)
        
        cell = tableView.cellForRow(at: indexPath) as! ChineseIDTableViewCell
        
        let spining2 = NVActivityIndicatorView(frame: CGRect(x: cell.frame.width/2-50, y: cell.frame.height/2-50, width: 100, height: 100), type:NVActivityIndicatorType(rawValue: 26), color:UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0))
        
        if self.client._backName != nil && indexPath.row == 1{
            cell.ID.image = UIImage(named: "blank")!
            spining2.startAnimating()
            cell.addSubview(spining2)
            downloadImageFromS3(imageKey: client._backName!, target: cell.ID){
                self.tableView.reloadData()
                self.tableView.frame = CGRect(x:self.screenWidth * 0.05, y:self.self.ChineseNumberField.frame.origin.y+self.ChineseNumberField.frame.size.height+10, width:self.screenWidth * 0.9, height:self.presenter.calculateHeightofTable())
                self.finalUIInitilise()
                spining2.stopAnimating()
                spining2.removeFromSuperview()
            }
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
            IDBeingChanged = nil
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        if IDBeingChanged == 0{
            self.info1 = info
        }else{
            self.info2 = info
        }
        
        let indexPath = IndexPath(row: IDBeingChanged, section: 0)
        
        let cell:ChineseIDTableViewCell = tableView.cellForRow(at: indexPath) as! ChineseIDTableViewCell
        
        cell.ID.image = resizeImage(image: image, targetSize: CGSize(width:600, height:600))
        
        tableView.reloadData()
        
        tableView.frame = CGRect(x:screenWidth * 0.05, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height+10, width:screenWidth * 0.9, height:self.presenter.calculateHeightofTable())
        finalUIInitilise()
    }
    
    @objc func saveCoverPhoto(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Notice", message: "Save to Photo Libary Successful", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            UIImageWriteToSavedPhotosAlbum((sender.view as! UIImageView).image!, nil, nil, nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(image.size.width > image.size.height) {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * heightRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //MARK: - Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  textField.text == "Address" || textField.text == "ID number" || textField.text == "Mobile Phone Number"{
            textField.text = ""
        }
    }
    
    func getTableView() -> UITableView {
        return tableView
    }
    
    func getClient() -> Client {
        return client
    }
    
    @objc func copyTestField(_ sender : UITapGestureRecognizer) -> Void {
        
        let tag = (sender.view as! UIImageView).tag
        
        switch tag {
        case 2001:
            UIPasteboard.general.string = fullNameField.text
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)

            break
        case 2002:
            UIPasteboard.general.string = mobileField.text
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)

            break
        case 2003:
            UIPasteboard.general.string = addressField.text
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)

            break
        case 2004:
            UIPasteboard.general.string = ChineseNumberField.text
            CommonUseClass._sharedManager.sendAlert(msg: "Copy Successful", view: self)

            break
        default:
            break
        }
    }
    
    //MARK: - functional
    func setSaveField(data: NSMutableArray, selectedField : String) {
        switch (selectedField)
        {
        case "mobile":
            client._mobile = data as? [String]
            dropDown.dataSource = self.presenter.convertToStringSet(selectField: data)
            dropDown.reloadAllComponents()
        case "ChineseID":
            client._chineseIDNumber = data as? [String]
            dropDownChineseNumber.dataSource = self.presenter.convertToStringSet(selectField: data)
            dropDownChineseNumber.reloadAllComponents()
        case"address":
            client._address = data as? [String]
            dropDownAddress.dataSource = self.presenter.convertToStringSet(selectField: data)
            dropDownAddress.reloadAllComponents()
        default:
            break
        }
        
        bindInfo()
        done()
    }
    
    
    @objc func showMobileList() -> Void {
        if client._mobile!.count <= 1{
            CommonUseClass._sharedManager.sendAlert(msg:  "You only have one mobile number, list is not shown", view: self)
        }
        else{
            dropDown.show()
        }
    }
    
    @objc func showAddressList() -> Void {
        if client._address!.count <= 1{
            CommonUseClass._sharedManager.sendAlert(msg:  "You only have one address, list is not shown", view: self)
        }
        else{
            dropDownAddress.show()
        }
    }
    
    @objc func showChineseList() -> Void {
        if client._chineseIDNumber!.count <= 1{
            CommonUseClass._sharedManager.sendAlert(msg:  "You only have one Chinese ID, list is not shown", view: self)
        }
        else{
            dropDownChineseNumber.show()
        }
    }
    
    //MARK: - Save&&Edit&Upload
    func uploadImageToS3(info : [String:Any], sideUpload : Int, completion: @escaping () -> ()) -> Void {
        
        SVProgressHUD.show()
        
        let uploadFileURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        
        let imageName = uploadFileURL.lastPathComponent
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let fileManager = FileManager.default
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: imageName)).jpeg")
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let fileUrl = NSURL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "auflyer-userfiles-mobilehub-1884545339"
        uploadRequest?.key = self.presenter.produceUniqueFileName() + ".jpeg"
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.body = (fileUrl as URL?)!
        uploadRequest?.serverSideEncryption = AWSS3ServerSideEncryption.awsKms
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                SVProgressHUD.showProgress(Float(totalBytesSent), status: "Uploading")
            })
        }
        
        // Push the image
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Upload failed (\(error))")
                completion()
            }
            if task.result != nil {
                if sideUpload == 0{
                    self.client._coverName = uploadRequest?.key
                }
                if sideUpload == 1{
                    self.client._backName = uploadRequest?.key                }
                completion()
            }
            else {
                completion()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    func downloadImageFromS3(imageKey : String, target : UIImageView, completion: @escaping () -> ()) -> Void {
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageKey)
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        
        downloadRequest?.bucket = "auflyer-userfiles-mobilehub-1884545339"
        downloadRequest?.key = imageKey
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                }
                completion()
                return nil
            }
            print("Download complete for: \(String(describing: downloadRequest?.key))")
            target.image =  self.resizeImage(image: UIImage(contentsOfFile: downloadingFileURL.path)!, targetSize: CGSize(width:600, height:600))
            completion()
            return nil
        })
    }
    
    @objc func chooseURLToUpload() -> Void {
        
        var hasPromt : Bool = false
        print("info1",info1)
        if info1 != nil{
            uploadImageToS3(info: info1, sideUpload: 0, completion: {
                hasPromt = true
                if self.info2 != nil{
                    self.uploadImageToS3(info: self.info2, sideUpload: 1, completion: {
                        self.done()
                    })
                }
                else{
                    self.done()
                }
            })
        }
        
        if !hasPromt && info1 == nil && info2 != nil{
            uploadImageToS3(info: info2, sideUpload: 1, completion: {
                self.done()
            })
        }
        
        if info1 == nil && info2 == nil{
            self.done()
        }
    }
    
    func insertFirstItem(array : NSMutableArray) -> [String] {
        if array as! Array<String> == client._address!{
            array[0] = addressField.text!
        }
        if array as! Array<String> == client._chineseIDNumber!{
            array[0] = ChineseNumberField.text!
        }
        return self.presenter.convertToStringSet(selectField: array)
    }
    
    func done() -> Void {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        client._userId = AWSIdentityManager.default().identityId
        client._fullname = fullNameField.text
        client._address = client._address
        client._mobile = client._mobile
        client._chineseIDNumber = client._chineseIDNumber
        
        //Save a item
        dynamoDbObjectMapper.save(client).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as NSError? {
                print("The request failed. Error: \(error)")
            } else {
                self.renewData.updateLocalData(newData: self.client)
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Notice", message: "Save Successful", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                        SVProgressHUD.dismiss()
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                })
            }
            return nil
        })
    }
    
    //MARK: - initialse data
    func bindInfo() -> Void {
        fullNameField.text = client._fullname
        mobileField.text = client._mobile?[0]
        addressField.text = client._address?[0]
        ChineseNumberField.text = client._chineseIDNumber?[0]
    }
    
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toEdit") {
            let nextView: EditInformationViewController? = segue.destination as? EditInformationViewController
            nextView?.data = self.presenter.convertToNSMutableArray(selectField: sender as! [String])
            nextView?.delegate = self 
            switch (self.presenter.convertToNSMutableArray(selectField: sender as! [String]))
            {
            case self.presenter.convertToNSMutableArray(selectField: client._mobile!):
                nextView?.currentSelectedField = "mobile"
            case self.presenter.convertToNSMutableArray(selectField: client._address!):
                nextView?.currentSelectedField = "address"
            case self.presenter.convertToNSMutableArray(selectField: client._chineseIDNumber!):
                nextView?.currentSelectedField = "ChineseID"
            default:
                break
            }
        }
    }
}
extension ClientDetailViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func setTable() {
        
        tableView = UITableView()
        
        tableView.frame = CGRect(x:screenWidth * 0.05, y:ChineseNumberField.frame.origin.y+ChineseNumberField.frame.size.height+10, width:screenWidth * 0.9, height:screenWidth * 0.9)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableHeaderView?.removeFromSuperview()
        automaticallyAdjustsScrollViewInsets = true
        
        tableView.keyboardDismissMode = .onDrag
        container.addSubview(tableView)
        
        let propertyNib = UINib(nibName:"ChineseIDTableViewCell", bundle: Bundle(for: ChineseIDTableViewCell.self))
        tableView.register(propertyNib, forCellReuseIdentifier: "ChineseIDTableViewCell1")
        
        let footer = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:ChineseIDTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ChineseIDTableViewCell1") as! ChineseIDTableViewCell
        
        cell.selectionStyle = .none
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.saveCoverPhoto(_:)))
        if cell.ID.image != UIImage(named: "addPhoto"){
            cell.ID.addGestureRecognizer(longPressRecognizer)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
        
        IDBeingChanged = indexPath.row
        
    }
}




