//
//  ExtensionClass.swift
//  Auflyer
//
//  Created by Yingyong on 2018/6/9.
//

import UIKit

class CommonUseClass: NSObject {
    
    static let _sharedManager = CommonUseClass()
    
    var productList : Set<String> = []
    
    override init() {
        super.init()
        
    }
    
    func getAllCells(tableView : UITableView) -> NSMutableArray {
        let sections: Int = tableView.numberOfSections
        let cells : NSMutableArray = NSMutableArray()
        for section in 0..<sections {
            let rows: Int = tableView.numberOfRows(inSection: section)
            for row in 0..<rows-1 {
                let indexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cells.add(cell)
                }
            }
        }
        
        return cells
    }
    
    func getMainColor() -> UIColor {
        return UIColor(red: 111/255, green: 201/255, blue: 199/255, alpha: 1.0)
    }
    
    func getNavigationBarHeight() -> CGFloat {
        if let navigationController = ((UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController)){
            return navigationController.navigationBar.frame.size.height +  navigationController.navigationBar.frame.origin.y
        }
        return 44
    }
    
    func sendAlert(msg : String, view : UIViewController) -> Void {
        let alert = UIAlertController(title: "Notice", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
}
extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    var isAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    func toStringClientName() -> String {
        return String(format: "%@ %@","ClientName:",self)
    }
    func convertToNSDateFromString() -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, dd, MMMM, yyyy， HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, dd, MMMM, yyyy， HH:mm:ss"
        
        return dateFormatterGet.date(from: self)!
    }
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        if formatter.number(from: self) != nil {
            
            let split = self.components(separatedBy: decimalSeparator)
            
            let digits = split.count == 2 ? split.last ?? "" : ""
            
            return digits.characters.count <= maxDecimalPlaces
        }
        
        return false
    }
}
extension Double {
    var hasDecimal: Bool {
        return rint(self) == self
    }
    func toStringWithTotal() -> String {
        return String(format: "%@ :%.0f","Total",self)
    }
    func toStringWithSymbol() -> String {
        if self.toString().count >= 3{
            return String(format: "%.0f$",self)
        }
        else{
            return String(format: "%.2f$",self)
        }
    }
    func toString() -> String {
        return String(format: "%.0f",self)
    }
    func remove$symbol() -> String {
        return String(format: "%.0f",self)
    }
}
