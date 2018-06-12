//
//  EditInformationViewController.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/12/10.
//

import UIKit
import SkyFloatingLabelTextField

class EditInformationViewController: UIViewController {

    //MARK: - Attributes
    var scrollView : UIScrollView!
    var data : NSMutableArray = NSMutableArray()
    var currentSelectedField :  String = String()
    var editView : UIView = UIView()
    var skyTextfiledArray : NSMutableArray = NSMutableArray()
    var saveButton : UIButton!
    var delegate : refreshFieldDelegate!

    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setNavigationBtn()
    }

    func setUI() -> Void {
        
        self.title = "Edit information"
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: scrrenHeight))
        scrollView.layer.cornerRadius = 4
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        self.view.addSubview(scrollView)
        
        editView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
        editView.backgroundColor = CommonUseClass._sharedManager.getMainColor()
        editView.layer.cornerRadius = 4
        scrollView.addSubview(editView)
        
        
        for index in 0..<data.count{
            let titleTextField = SkyFloatingLabelTextField(frame: CGRect(x:editView.frame.size.width * 0.05 ,y: editView.frame.size.height * 0.1 * CGFloat(index) + 30,width: editView.frame.size.width * 0.9,height: 40))
            titleTextField.font = UIFont.systemFont(ofSize:15)
            
            titleTextField.text = data[index] as? String

            switch (titleTextField.text)
            {
                
            case "Mobile Phone Number":
                
                titleTextField.placeholder = data[index] as? String
                titleTextField.text = "";
                
            case "Address":
                
                titleTextField.placeholder = data[index] as? String
                titleTextField.text = "";

            case "ID number":
                
                titleTextField.placeholder = data[index] as? String
                titleTextField.text = "";

            default:
                titleTextField.text = data[index] as? String
                break
            }

            
            switch (currentSelectedField)
            {
            case "mobile":
                titleTextField.title = String(format: "%@ %@", "Mobile Number", String(index+1))
            case "ChineseID":
                titleTextField.title = String(format: "%@ %@", "Chinese ID Number", String(index+1))
            case "address":
                titleTextField.title = String(format: "%@ %@", "Address", String(index+1))
            default:
                break
            }
            titleTextField.placeholderColor = UIColor.white
            titleTextField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
            titleTextField.textColor = UIColor.white
            titleTextField.lineColor = UIColor.white
            titleTextField.selectedTitleColor = UIColor.gray
            titleTextField.selectedLineColor = UIColor.white
            titleTextField.delegate = self as? UITextFieldDelegate
            titleTextField.tag = index
            titleTextField.lineHeight = 1.0 // bottom line height in points
            titleTextField.selectedLineHeight = 2.0
            editView.addSubview(titleTextField)
            skyTextfiledArray.add(titleTextField)
        }
        
        createSaveButton()
    }
    
    func createSaveButton() -> Void {
        let lastObjectField = (skyTextfiledArray.lastObject as! SkyFloatingLabelTextField)
        
        saveButton = UIButton(frame: CGRect(x: 0, y: lastObjectField.frame.size.height + lastObjectField.frame.origin.y + 30, width: screenWidth, height: scrrenHeight * 0.08))
        saveButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 14))!
        saveButton.titleLabel?.textAlignment = .center
        saveButton.setTitleColor(CommonUseClass._sharedManager.getMainColor(), for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 3.0
        saveButton.layer.masksToBounds = true
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.backgroundColor = UIColor.white.cgColor
        saveButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        editView.addSubview(saveButton)
    }
    
    @objc func save() -> Void {
        let tempArray : NSMutableArray = NSMutableArray()
        for index in 0..<skyTextfiledArray.count{
            
            let textField = skyTextfiledArray[index] as! SkyFloatingLabelTextField
            
            if textField.text == "" && currentSelectedField == "mobile" && skyTextfiledArray.count == 1
            {
                textField.text = "Mobile Phone Number"
            }
            else if textField.text == "" && currentSelectedField == "ChineseID" && skyTextfiledArray.count == 1
            {
                textField.text = "ID number"
            }
            else if textField.text == "" && currentSelectedField == "address" && skyTextfiledArray.count == 1
            {
                textField.text = "Address"
            }

            if textField.text == "" {
                skyTextfiledArray.remove(textField)
            }
            else{
                tempArray.add(textField.text!)
            }
            
        }
        self.delegate.setSaveField(data: tempArray, selectedField : currentSelectedField)
    }
    
    func setNavigationBtn() -> Void {
        let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(40)))
        button.setImage(UIImage(named: "plus1"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(addNew), for: .touchUpInside)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        let navButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = navButton;
    }
    
    func setScrollView() -> Void {
        
        scrollView.contentSize = CGSize(width: CGFloat(screenWidth), height: CGFloat(editView.frame.size.height))
    }
    
    @objc func addNew(){
        
        if skyTextfiledArray.count >= 6{
            CommonUseClass._sharedManager.sendAlert(msg: "You have reach the limit of maxium storage", view: self)
            return;
        }
        
        if (skyTextfiledArray.lastObject as! SkyFloatingLabelTextField).text == ""
        {
            CommonUseClass._sharedManager.sendAlert(msg: "You have one empty field already", view: self)
            return
        }
        
        let titleTextField = SkyFloatingLabelTextField(frame: CGRect(x:editView.frame.size.width * 0.05 ,y: editView.frame.size.height * 0.1 * CGFloat(skyTextfiledArray.count) + 30,width: editView.frame.size.width * 0.9,height: 40))
        titleTextField.font = UIFont.systemFont(ofSize:15)
        
        switch (currentSelectedField)
        {
        case "mobile":
            titleTextField.title = String(format: "%@ %@", "Mobile Number", String(skyTextfiledArray.count+1))
            titleTextField.placeholder = "Mobile Number"
        case "ChineseID":
            titleTextField.title = String(format: "%@ %@", "Chinese ID Number", String(skyTextfiledArray.count+1))
            titleTextField.placeholder = "Chinese ID Number"
        case"address":
            titleTextField.title = String(format: "%@ %@", "Address", String(skyTextfiledArray.count+1))
            titleTextField.placeholder = "Address"
        default:
            break
        }
        titleTextField.placeholderColor = UIColor.white
        titleTextField.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        titleTextField.textColor = UIColor.white
        titleTextField.lineColor = UIColor.white
        titleTextField.selectedTitleColor = UIColor.gray
        titleTextField.selectedLineColor = UIColor.white
        titleTextField.delegate = self as? UITextFieldDelegate
        titleTextField.tag = skyTextfiledArray.count
        titleTextField.lineHeight = 1.0 // bottom line height in points
        titleTextField.selectedLineHeight = 2.0
        editView.addSubview(titleTextField)
        skyTextfiledArray.add(titleTextField)
        
        if saveButton != nil{
            saveButton.removeFromSuperview()
        }
        
        createSaveButton()
        
        setScrollView()
    }
}

