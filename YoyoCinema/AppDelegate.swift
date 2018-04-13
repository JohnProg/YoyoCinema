//
//  AppDelegate.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 15/03/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import NStackSDK
import RealmSwift
import CoreLocation
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //NOTIFICATION
        // Defaults to any value in AirshipConfig.plist
        let config = UAConfig.default()
        UAirship.takeOff(config)
        
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().defaultPresentationOptions = [.alert, .badge, .sound]
        
        //MAP
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        //GOOGLE ANALYTICS
        AnalyticsManager.sharedInstance.initializeAnalytics()

        //FACEBOOK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //NSTACK
        let configuration = Configuration(plistName: "NStack", translationsClass: Translations.self)
        NStack.start(configuration: configuration, launchOptions: launchOptions)
        
        //REALM
        //to get Realm file
        print("location of realm file: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        do {
            _ = try Realm()
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        AnalyticsManager.sharedInstance.registerAction(category: "App", action: "App open action", label: "Success")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options [UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: [UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

