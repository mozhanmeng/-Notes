//
//  RecordDetailTableViewCell.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/5.
//

import UIKit
import SkyFloatingLabelTextField
import Bond
import DropDown

class RecordDetailTableViewCell: UITableViewCell {
    
    var productName : SkyFloatingLabelTextField!
    var priceIn : SkyFloatingLabelTextField!
    var priceOut : SkyFloatingLabelTextField!
    var profit : SkyFloatingLabelTextField!
    var indexTag : NSInteger!
    var accessoryButton : UIButton?
    var matchedProducts : [String] = []
    var dropDown = DropDown()
    
    typealias calculateTotal = (_ buyIn : Double,_ sellOut : Double,_ profit : Double, _ indexTag : NSInteger)-> ()
    var calculateTotalBlock : calculateTotal!
    
    typealias findMatch = (_ productName : String)-> [String]
    var findMatchBlock : findMatch!
    
    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height * 0.15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
        
        createKeywordPromt()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessoryButton?.tintColor = CommonUseClass._sharedManager.getMainColor()
        accessoryButton?.frame.origin.x = self.frame.width * 0.865
        accessoryButton?.frame.origin.y = self.frame.height/2 - (accessoryButton?.frame.height)! - 5
    }
    
    func setUI() -> Void {
        
        productName = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.01, y:scrrenHeight * 0.01, width:screenWidth * 0.3, height:UIScreen.main.bounds.size.height * 0.1))
        productName.placeholder = "Product Name"
        productName.title = "Product Name"
        
        productName.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        productName.textColor = CommonUseClass._sharedManager.getMainColor()
        productName.lineColor = CommonUseClass._sharedManager.getMainColor()
        productName.delegate = self as UITextFieldDelegate
        productName.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        productName.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        productName.lineHeight = 1.0 // bottom line height in points
        productName.selectedLineHeight = 2.0
        productName.addTarget(self, action: #selector(RecordDetailTableViewCell.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.addSubview(productName)
        
        let _ = productName.reactive.text.observeNext { text in
            if let _ = self.findMatchBlock{
                self.matchedProducts = self.findMatchBlock(text!)
                self.dropDown.dataSource = self.matchedProducts
            }
        }
        
        priceIn = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.35, y:scrrenHeight * 0.01, width:screenWidth * 0.15, height:UIScreen.main.bounds.size.height * 0.1)
        )
        priceIn.placeholder = "in"
        priceIn.title = "in"
        priceIn.delegate = self as UITextFieldDelegate
        priceIn.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        priceIn.textColor = CommonUseClass._sharedManager.getMainColor()
        priceIn.lineColor = CommonUseClass._sharedManager.getMainColor()
        priceIn.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        priceIn.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        priceIn.lineHeight = 1.0
        self.addSubview(priceIn)
        
        let _ = priceIn.reactive.text.observeNext { text in

            if  !(text?.isEmpty)! && !(self.priceOut.text?.isEmpty)! && ((text?.isNumber)! || (self.priceOut.text?.isNumber)! || (text?.isValidDouble(maxDecimalPlaces: 1))! || (self.priceOut.text?.isValidDouble(maxDecimalPlaces: 1))!){
                
                self.calculateProfit()
            }
        }
        
        priceOut = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.55, y:scrrenHeight * 0.01, width:screenWidth * 0.15, height:UIScreen.main.bounds.size.height * 0.1))
        priceOut.placeholder = "out"
        priceOut.title = "out"
        priceOut.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        priceOut.textColor = CommonUseClass._sharedManager.getMainColor()
        priceOut.delegate = self as UITextFieldDelegate
        priceOut.lineColor = CommonUseClass._sharedManager.getMainColor()
        priceOut.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        priceOut.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        priceOut.lineHeight = 1.0 // bottom line height in points
        priceOut.selectedLineHeight = 2.0
        self.addSubview(priceOut)
        
        let _ = priceOut.reactive.text.observeNext { text in
            if !(text?.isEmpty)! && ((text?.isNumber)! || (self.priceIn.text?.isNumber)! || (text?.isValidDouble(maxDecimalPlaces: 1))! || (self.priceIn.text?.isValidDouble(maxDecimalPlaces: 1))!) && !(self.priceIn.text?.isEmpty)!{
                
                self.calculateProfit()
            }
        }
        
        profit = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.75, y:scrrenHeight * 0.01, width:screenWidth * 0.15, height:UIScreen.main.bounds.size.height * 0.1))
        profit.placeholder = "Profit"
        profit.title = "Profit"
        
        profit.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        profit.textColor = CommonUseClass._sharedManager.getMainColor()
        profit.lineColor = CommonUseClass._sharedManager.getMainColor()
        profit.delegate = self as UITextFieldDelegate
        profit.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        profit.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        profit.lineHeight = 1.0 // bottom line height in points
        profit.isUserInteractionEnabled = false
        profit.selectedLineHeight = 2.0
        self.addSubview(profit)
        
    }
    
    func createKeywordPromt() -> Void {
        
        let dropDownView = UIView(frame: CGRect(x:screenWidth * 0.01, y:productName.frame.origin.y, width:screenWidth * 0.3, height:scrrenHeight * 0.08))
        self.addSubview(dropDownView)
        
        dropDown = DropDown()
        dropDown.direction = .top
        dropDown.dismissMode = .onTap
        dropDown.anchorView = dropDownView // UIView or UIBarButtonItem
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.productName.text = item
        }
    }
    
    func setTotalPrice(_ totalBuyIn : Double,_ totalSellOut : Double,_ totalProfit : Double) -> Void {
        productName.title = "TOTAL PRICE"
        productName.text = "TOTAL PRICE"
        
        priceIn.title = "TOTAL"
        priceIn.isUserInteractionEnabled = false
        priceIn.text = totalBuyIn.toStringWithSymbol()
        
        priceOut.title = "TOTOL"
        priceOut.isUserInteractionEnabled = false
        priceOut.text = totalSellOut.toStringWithSymbol()
        
        profit.title = "TOTAL"
        profit.isUserInteractionEnabled = false
        profit.text = totalProfit.toStringWithSymbol()
    }
    
    func bindData(record : TransacationRecord, indexPath : IndexPath) -> Void {
        productName.text = record._productNames?[indexPath.row]
        priceIn.text = record._priceBuyIn?[indexPath.row]
        priceOut.text = record._priceSellOut?[indexPath.row]
        
        calculateProfit()
    }
    
    func calculateProfit() -> Void {
        let characterset = CharacterSet(charactersIn: ".0123456789")
        if (self.priceIn.text?.rangeOfCharacter(from: characterset.inverted) != nil || self.priceOut.text?.rangeOfCharacter(from: characterset.inverted) != nil) {
            print("string contains special characters")
            return
        }else{
            let priceIn = self.priceIn.text?.toDouble()
            let priceOut = self.priceOut.text?.toDouble()
            let totalProfit : Double = priceOut! - priceIn!
            
            self.profit.text = totalProfit.toStringWithSymbol()
            
            if let _ = calculateTotalBlock{
                calculateTotalBlock(priceIn!, priceOut!, totalProfit, self.indexTag)
            }
        }
    }
}
extension RecordDetailTableViewCell : UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.dropDown.show()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tempString = textField.text! + string
        if textField.text?.count == 0 && string == "." && textField != productName || (tempString.contains("..")){
            return false
        }
        if textField == productName{
            return true
        }
        if textField.text != nil {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                let characterset = CharacterSet(charactersIn: ".0123456789")
                if (self.priceIn.text?.rangeOfCharacter(from: characterset.inverted) != nil || self.priceOut.text?.rangeOfCharacter(from: characterset.inverted) != nil) {
                    print("string contains characters except .0123456789 -> including dot . ")
                    floatingLabelTextField.errorMessage = "Invalid"
                }
                else {
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
        return true
    }
    
}
