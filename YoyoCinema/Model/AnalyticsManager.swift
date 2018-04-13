//
//  Analytics.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 03/04/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

class AnalyticsManager : NSObject {
    static let sharedInstance = AnalyticsManager()
    
    func initializeAnalytics() {
        // Configure tracker from GoogleService-Info.plist.
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
        }
        gai.tracker(withTrackingId: "UA-116591047-1")
        
    }
    
    func registerScreen(screenName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build()! as! [NSObject : AnyObject])
    }
    
    func registerAction(category: String, action: String, label: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil)
        tracker?.send(dict?.build() as! [NSObject : AnyObject])
    }
}

