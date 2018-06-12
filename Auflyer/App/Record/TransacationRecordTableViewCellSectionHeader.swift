//
//  TransacationRecordSectionHeader.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/30.
//

import UIKit

class TransacationRecordSectionHeader: UIView {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var totalEarned: UILabel!
    @IBOutlet weak var foldButton: UIButton!
    
    typealias callBackBlock = (_ index : NSInteger,_ isSelected : Bool)->()
    
    var spreadBlock : callBackBlock!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.blue
        let subView : UIView = Bundle.main.loadNibNamed("TransacationRecordSectionHeader", owner: self, options: nil)?.first as! UIView
        subView.frame = self.frame
        self.addSubview(subView)
        foldButton.tintColor = UIColor.clear
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    @IBAction func spreadBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let _ = spreadBlock{
            spreadBlock(self.tag,sender.isSelected)
        }
    }

}
