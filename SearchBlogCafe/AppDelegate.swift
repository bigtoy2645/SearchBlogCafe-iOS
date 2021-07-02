//
//  AppDelegate.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DropDown.startListeningToKeyboard()
        return true
    }
}

