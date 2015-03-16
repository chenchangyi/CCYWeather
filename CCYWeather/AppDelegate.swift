//
//  AppDelegate.swift
//  CCYWeather
//
//  Created by chenchangyi on 15/3/2.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import UIKit
import CoreData

private let coreDataHelper = CoreDataHelper()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    class var cdh:CoreDataHelper {
        coreDataHelper.setupCoreData()
        return coreDataHelper
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("isFirst") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirst")
            self.creatDefultData()
            AppDelegate.cdh.saveContext()
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.rootViewController = CYViewController()
        self.window?.makeKeyAndVisible()
        

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

        AppDelegate.cdh.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {

        AppDelegate.cdh.saveContext()
    }
    
    func creatDefultData(){
        let entity = NSEntityDescription.entityForName("CurrentWeather", inManagedObjectContext: AppDelegate.cdh.context)
        CurrentWeather(entity: entity!, insertIntoManagedObjectContext: AppDelegate.cdh.context)
        
        for _ in 1...7 {
        let entity1 = NSEntityDescription.entityForName("HourForcast", inManagedObjectContext: AppDelegate.cdh.context)
        HourForcast(entity: entity1!, insertIntoManagedObjectContext: AppDelegate.cdh.context)
        }
        
        for _ in 1...7 {
            let entity1 = NSEntityDescription.entityForName("DayForcast", inManagedObjectContext: AppDelegate.cdh.context)
            DayForcast(entity: entity1!, insertIntoManagedObjectContext: AppDelegate.cdh.context)
        }
    }

}

