  //
  //  AppDelegate.swift
  //  Auflyer
  //
  //  Created by YingyongZheng on 2017/11/17.
  //  Copyright © 2017年 YingyongZheng. All rights reserved.
  //
  import UIKit
  import AWSCognito
  import AWSCore
  import AWSMobileClient
  import AWSGoogleSignIn
  import AWSAuthUI
  import IQKeyboardManager
  import AWSS3
  import DropDown
  
  @UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isInitialized: Bool = false
    var isLogin : Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        Timer.scheduledTimer(timeInterval: 3660, target: self, selector: #selector(configS3), userInfo: nil, repeats: true)

        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.white
        DropDown.appearance().backgroundColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0)
        
        UITabBar.appearance().tintColor =  UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0)
        //        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0)], for: .selected)
        
        IQKeyboardManager.shared().isEnabled = true
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red: 111 / 255.0, green: 201 / 255.0, blue: 199 / 255.0, alpha: 1.0)


        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSSignInManager.sharedInstance().register(signInProvider: AWSGoogleSignInProvider.sharedInstance())
        _ = AWSSignInManager.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        if (!isInitialized) {
            AWSSignInManager.sharedInstance().resumeSession(completionHandler: { (result: Any?, error: Error?) in
                print("Result: \(String(describing: result)) \n Error:\(String(describing: error))")
            })
            isInitialized = true
        }
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, didFinishLaunchingWithOptions:
            launchOptions)
        
    }
    
    //MARK: - AWS S3 Management
    @objc func configS3() -> Void {
        
        let CognitoPoolID = "us-east-1:8d6b576c-d3ff-4779-bd58-aaa1b2661975"
        let Region = AWSRegionType.USEast1
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,
                                                                identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func switchBack() {
        
        // switch back to view controller 1
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "rootViewController")
        
        self.window?.rootViewController = nav
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Store the completion handler.
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Timer.scheduledTimer(timeInterval: 3660, target: self, selector: #selector(configS3), userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Timer.scheduledTimer(timeInterval: 3660, target: self, selector: #selector(configS3), userInfo: nil, repeats: true)
    }
    
    
  }
  
