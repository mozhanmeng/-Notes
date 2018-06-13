//
//  TotalResultsTableViewCell.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/7.
//

import UIKit
import SkyFloatingLabelTextField

class TotalResultsTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var moneyEarnedLabel : SkyFloatingLabelTextField!
    var priceIn : SkyFloatingLabelTextField!
    var priceOut : SkyFloatingLabelTextField!
    var totalprofit : SkyFloatingLabelTextField!
    
    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height * 0.15
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setUI()
    }

    func setUI() -> Void {
        
        moneyEarnedLabel = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.01, y:scrrenHeight * 0.01, width:screenWidth * 0.5, height:UIScreen.main.bounds.size.height * 0.1))
        moneyEarnedLabel.title = "TOTAL MONEY EARNED"
        moneyEarnedLabel.text = "TOTAL MONEY EARNED"
        moneyEarnedLabel.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        moneyEarnedLabel.textColor = UIColor.red
        moneyEarnedLabel.lineColor = UIColor.red
        moneyEarnedLabel.isUserInteractionEnabled = false
        moneyEarnedLabel.delegate = self as UITextFieldDelegate
        moneyEarnedLabel.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        moneyEarnedLabel.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        moneyEarnedLabel.lineHeight = 1.0 // bottom line height in points
        moneyEarnedLabel.selectedLineHeight = 2.0
        self.addSubview(moneyEarnedLabel)

        totalprofit = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.7, y:scrrenHeight * 0.01, width:screenWidth * 0.2, height:UIScreen.main.bounds.size.height * 0.1))
        totalprofit.placeholder = "TOTAL"
        totalprofit.title = "TOTAL"
        totalprofit.isUserInteractionEnabled = false
        totalprofit.tintColor = CommonUseClass._sharedManager.getMainColor() // the color of the blinking cursor
        totalprofit.textColor = UIColor.black
        totalprofit.lineColor = UIColor.red
        totalprofit.delegate = self as UITextFieldDelegate
        totalprofit.selectedTitleColor = CommonUseClass._sharedManager.getMainColor()
        totalprofit.selectedLineColor = CommonUseClass._sharedManager.getMainColor()
        totalprofit.lineHeight = 1.0 // bottom line height in points
        totalprofit.isUserInteractionEnabled = false
        totalprofit.selectedLineHeight = 2.0
        self.addSubview(totalprofit)
        
    }
    
    func setTotalPrice(_ totalBuyIn : Double,_ totalSellOut : Double,_ totaltotalprofit : Double) -> Void {
        
        totalprofit.text = totaltotalprofit.toStringWithSymbol()
    }
    
}
