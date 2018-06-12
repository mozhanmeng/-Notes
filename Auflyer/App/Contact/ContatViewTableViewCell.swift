//
//  ContatViewTableViewCell.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/11/27.
//

import UIKit

class ContatViewTableViewCell: UITableViewCell {

    var screenWidth : CGFloat!
    var scrrenHeight : CGFloat!
    var nameLabel : UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        screenWidth = UIScreen.main.bounds.size.width
        scrrenHeight = UIScreen.main.bounds.size.height
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(client : Client) -> Void {
        
        nameLabel.removeFromSuperview()
        
        nameLabel = UILabel(frame: CGRect(x: screenWidth * 0.05, y: scrrenHeight * 0.02, width: screenWidth * 0.9, height: scrrenHeight * 0.05))
        nameLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(screenWidth * 0.045))
        nameLabel.text = client._fullname
        nameLabel.textAlignment = .left
        self.addSubview(nameLabel)
    }
}
