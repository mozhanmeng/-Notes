//
//  DisplayWebViewController.swift
//  Auflyer
//
//  Created by YingyongZheng on 2017/12/13.
//

import UIKit
import WebKit
import NVActivityIndicatorView

class DisplayWebViewController: UIViewController,WKNavigationDelegate {

    var webView : WKWebView!
    var urlString : String = String()
    var spining :  NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpWKwebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.startAnimating(type: 22)
    }
    
    func setUpWKwebView() {
        
        let webConfiguration = WKWebViewConfiguration()

        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), configuration: webConfiguration)
        webView.navigationDelegate = self
        
        let myRequest = URLRequest(url:URL(string:urlString)!)
        webView.load(myRequest)
        self.view.addSubview(webView)
        
    }
    
    func webView(_ webView: WKWebView,
                          didFinish navigation: WKNavigation!){
        self.stopAnimating()
    }
    
    func startAnimating(type : Int) -> Void {
        spining = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2-50, y: self.view.frame.height/2-50, width: 100, height: 100), type:NVActivityIndicatorType(rawValue: type), color:UIColor(red: 111/255, green: 201/255, blue: 199/255, alpha: 1.0))
        spining.startAnimating()
        self.view.addSubview(spining)
    }
    
    func stopAnimating() -> Void {
        spining.stopAnimating()
        spining.removeFromSuperview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        self.stopAnimating()

    }
}
