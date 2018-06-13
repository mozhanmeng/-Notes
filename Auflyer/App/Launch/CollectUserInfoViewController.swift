//
//  CollectUserInfoViewController.swift
//  AuFlyer
//
//  Created by YingyongZheng on 2017/11/26.
//

import UIKit
import AWSDynamoDB
import AWSCognito
import AWSCore
import AWSAuthUI
import AWSGoogleSignIn
import SkyFloatingLabelTextField

class CollectUserInfoViewController: UIViewController {
    
    var screenWidth : CGFloat = UIScreen.main.bounds.size.width
    var scrrenHeight : CGFloat = UIScreen.main.bounds.size.height
    var fullNameField : SkyFloatingLabelTextField!
    var lastNameField : SkyFloatingLabelTextField!
    var mobileField : SkyFloatingLabelTextField!
    var emailField : SkyFloatingLabelTextField!
    var landingPage : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        login()
        
    }
    
    @objc func removeLandingPage() -> Void {
        landingPage.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        landingPage = UIImageView()
        landingPage.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.scrrenHeight)
        landingPage.image = UIImage(named:"LandingPage")
        landingPage.clipsToBounds = true
        UIApplication.shared.keyWindow?.addSubview(self.landingPage)
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(removeLandingPage), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        landingPage.removeFromSuperview()
    }
    
    func login() -> Void {
        self.PresentLoginScreen(){
            self.registerCredential()
        }
    }
    
    func registerCredential() -> Void {
        DispatchQueue.main.async {
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:8d6b576c-d3ff-4779-bd58-aaa1b2661975")
            let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
            
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            AWSLogger.default().logLevel = .verbose
            AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
            AWSDDLog.sharedInstance.logLevel = .info
            
            self.checkInfoFilled()
        }
    }
    
    func setUI() -> Void {
        
        self.title = "Register"
        
        let informBoard = UIView(frame: CGRect(x: screenWidth * 0.05, y: scrrenHeight * 0.13, width: screenWidth * 0.9, height: scrrenHeight * 0.05))
        informBoard.backgroundColor = UIColor.white
        informBoard.layer.cornerRadius = 4
        informBoard.layer.borderWidth = 1
        informBoard.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0)
        informBoard.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        view.addSubview(informBoard)
        
        let informInfo = UILabel(frame:CGRect(x: 0, y: scrrenHeight * 0.13, width: screenWidth, height: scrrenHeight * 0.05))
        informInfo.font = UIFont.boldSystemFont(ofSize: CGFloat(screenWidth * 0.04))
        informInfo.textAlignment = .center
        informInfo.textColor = .white
        informInfo.text = "Please fill in information to register"
        view.addSubview(informInfo)
        
        let lightGreyColor = UIColor(red: 111/255, green: 201/255, blue: 199/255, alpha: 1.0)
        
        fullNameField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.2, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        fullNameField.placeholder = "Full Name"
        fullNameField.title = "Full Name"
        
        fullNameField.tintColor = lightGreyColor // the color of the blinking cursor
        fullNameField.textColor = lightGreyColor
        fullNameField.lineColor = lightGreyColor
        fullNameField.selectedTitleColor = lightGreyColor
        fullNameField.selectedLineColor = lightGreyColor
        
        fullNameField.lineHeight = 1.0 // bottom line height in points
        fullNameField.selectedLineHeight = 2.0
        view.addSubview(fullNameField)
        
        emailField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.4, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        emailField.placeholder = "Mobile Phone Number"
        emailField.title = "Mobile Phone Number"
        
        emailField.tintColor = lightGreyColor // the color of the blinking cursor
        emailField.textColor = lightGreyColor
        emailField.lineColor = lightGreyColor
        emailField.selectedTitleColor = lightGreyColor
        emailField.selectedLineColor = lightGreyColor
        
        emailField.lineHeight = 1.0 // bottom line height in points
        emailField.selectedLineHeight = 2.0
        view.addSubview(emailField)
        
        mobileField = SkyFloatingLabelTextField(frame: CGRect(x:screenWidth * 0.05, y:scrrenHeight * 0.3, width:screenWidth * 0.9, height:scrrenHeight * 0.08))
        mobileField.placeholder = "Email Address"
        mobileField.title = "Email Address"
        
        mobileField.tintColor = lightGreyColor // the color of the blinking cursor
        mobileField.textColor = lightGreyColor
        mobileField.lineColor = lightGreyColor
        mobileField.selectedTitleColor = lightGreyColor
        mobileField.selectedLineColor = lightGreyColor
        
        mobileField.lineHeight = 1.0 // bottom line height in points
        mobileField.selectedLineHeight = 2.0
        view.addSubview(mobileField)
        
        let registerButton = UIButton(frame: CGRect(x: 0, y: scrrenHeight * 0.55, width: screenWidth, height: scrrenHeight * 0.08))
        registerButton.titleLabel?.font = (UIFont(name: "Helvetica-Bold", size: 11.0))!
        registerButton.titleLabel?.textAlignment = .center
        registerButton.setTitleColor(UIColor.white, for: .normal)
        registerButton.setTitle("Register", for: .normal)
        registerButton.layer.cornerRadius = 3.0
        registerButton.layer.masksToBounds = true
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        registerButton.layer.borderColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0).cgColor
        registerButton.addTarget(self, action: #selector(checkFillAllField), for: .touchUpInside)
        view.addSubview(registerButton)
    }
    
    @objc func checkFillAllField() -> Void {
        if fullNameField.text == "" || emailField.text == "" || mobileField.text == "" {
            CommonUseClass._sharedManager.sendAlert(msg: "Please fill all the gap", view: self)
            return
        }
        register()
    }
    
    func register() -> Void {
        
        let dataset : AWSCognitoDataset = AWSCognito.default().openOrCreateDataset("user_data")
        dataset.setString(fullNameField.text, forKey:"FullName")
        dataset.setString(emailField.text, forKey:"Email")
        dataset.setString(mobileField.text, forKey:"Mobile")
        dataset.setString("true", forKey:"DoneFillInfo")
        dataset.synchronize()
        
        self.performSegue(withIdentifier: "toMain", sender: nil)
    }
    
    func PresentLoginScreen(completion: @escaping () -> ()) -> Void {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = false
            config.backgroundColor = UIColor(red: 111/255.0, green: 201/255.0, blue: 199/255.0, alpha: 1.0)
            config.font = UIFont (name: "Helvetica Neue", size: 20)
            config.isBackgroundColorFullScreen = false
            config.canCancel = false
            config.logoImage = UIImage(named:"LOGO")
            config.addSignInButtonView(class: AWSGoogleSignInButton.self)
            
            AWSAuthUIViewController.presentViewController(with: self.navigationController!,
                                                          configuration: config,
                                                          completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                                            if error != nil {
                                                                print("Error occurred: \(String(describing: error))")
                                                                completion()
                                                            } else {
                                                                // Sign in successful.
                                                                completion()
                                                            }
            })
        }
        else
        {
            completion()
        }
    }
    
    func checkInfoFilled() {
        
        let syncClient: AWSCognito = AWSCognito.default()
        let userSettings: AWSCognitoDataset = syncClient.openOrCreateDataset("user_data")
        
        userSettings.synchronize().continueWith { (task: AWSTask<AnyObject>) -> Any? in
            if let error = task.error as NSError? {
                print("loadSettings error: \(error.localizedDescription)")
                return nil;
            }
            if userSettings.string(forKey: "DoneFillInfo") != "true" || userSettings.string(forKey: "DoneFillInfo") == nil{
                DispatchQueue.main.async {
                    self.setUI()
                }
            }
            else
            {
                self.performSegue(withIdentifier: "toMain", sender: nil)
            }
            return nil;
        }
    }
    
    
    
}

