//
//  ChineseIDTableViewCell.swift
//  Auflyer
//
//  Created by Yingyong on 2018/5/26.
//

import UIKit

class ChineseIDTableViewCell: UITableViewCell {

    @IBOutlet weak var ID: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ID.image = UIImage(named: "addPhoto")!
        self.ID.layer.cornerRadius = 4
        self.ID.layer.borderWidth = 1
        self.ID.backgroundColor = .clear
        self.ID.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        self.ID.isUserInteractionEnabled = true
        self.ID.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
