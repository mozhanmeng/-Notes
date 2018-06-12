
//
//  UploadIDViewController.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/12/13.
//

import UIKit
import WebKit
import SVProgressHUD

class UploadIDViewController: UIViewController {
    
    //MARK: - webviewDestination
    let PCAExpress = "https://www.pcaexpress.com.au/upload-chinese-id/"
    let ewe = "https://id.ewe.com.au/oms/contacts/upload"
    let blueSkyExpress = "http://track.blueskyexpress.com.au/wID/"
    let aol = "http://www.aol-au.com"
    let auExpress = "http://www.auexpress.com.au/PhotoIdUpload.aspx?msg=UVZWRg%3d%3d"
    let zhonghuan = "http://www.zhonghuan.com.au/clientController.do?idcardprocessing_add"
    let changjiang = "http://www.changjiangexpress.com/Home/Upload"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var PCAExpressIcon: UIImageView!
    @IBOutlet weak var EWEIcon: UIImageView!
    @IBOutlet weak var BSEIcon: UIImageView!
    @IBOutlet weak var AOLIcon: UIImageView!
    @IBOutlet weak var AuExpressIcon: UIImageView!
    @IBOutlet weak var zhonghuanIcon: UIImageView!
    @IBOutlet weak var changjiangIcon: UIImageView!

    var myURL : URL!

    //MARK: - ConstScreenBounds
    let screenWidth : CGFloat = UIScreen.main.bounds.size.width
    let scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        SVProgressHUD.dismiss()
        
    }

    func setUI() -> Void {
        
        self.title = "Upload ChineseID"
        

        PCAExpressIcon.tag = 1
        let coverTap = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        PCAExpressIcon.addGestureRecognizer(coverTap)

        BSEIcon?.tag = 2
        let coverTap2 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        BSEIcon.addGestureRecognizer(coverTap2)

        EWEIcon?.tag = 3
        let coverTap3 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        EWEIcon.addGestureRecognizer(coverTap3)

        AOLIcon?.tag = 4
        let coverTap4 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        AOLIcon.addGestureRecognizer(coverTap4)
        

        AuExpressIcon?.tag = 5
        let coverTap5 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        AuExpressIcon.addGestureRecognizer(coverTap5)
        

        zhonghuanIcon?.tag = 6
        let coverTap6 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        zhonghuanIcon.addGestureRecognizer(coverTap6)
        

        changjiangIcon?.tag = 7
        let coverTap7 = UITapGestureRecognizer(target: self, action: #selector(self.productURL(_:)))
        changjiangIcon.addGestureRecognizer(coverTap7)
        
        for index in 0...7{
            if let imageView = self.view.viewWithTag(index) as? UIImageView {
                imageView.isUserInteractionEnabled = true
                imageView.backgroundColor = UIColor.clear
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 4
                imageView.backgroundColor = .clear
                imageView.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func productURL(_ viewTag: UITapGestureRecognizer) -> Void {
        switch(viewTag.view?.tag)
        {
        case 1?:
            self.performSegue(withIdentifier: "pushToWebview", sender: PCAExpress)
        case 2?:
            self.performSegue(withIdentifier: "pushToWebview", sender: blueSkyExpress)
        case 3?:
            self.performSegue(withIdentifier: "pushToWebview", sender: ewe)
        case 4?:
            self.performSegue(withIdentifier: "pushToWebview", sender: aol)
        case 5?:
            self.performSegue(withIdentifier: "pushToWebview", sender: auExpress)
        case 6?:
            self.performSegue(withIdentifier: "pushToWebview", sender: zhonghuan)
        case 7?:
            self.performSegue(withIdentifier: "pushToWebview", sender: changjiang)
        default:
            break
        }
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "pushToWebview") {
            let nextView: DisplayWebViewController? = segue.destination as? DisplayWebViewController
            nextView?.urlString = sender! as! String
        }
    }
}
