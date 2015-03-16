//
//  CoreDataHelper.swift
//  CCYWeather
//
//  Created by chenchangyi on 15/3/11.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import UIKit
import CoreData
public class CoreDataHelper: NSObject {
    
    let context:NSManagedObjectContext
    let model:NSManagedObjectModel
    let coordinator:NSPersistentStoreCoordinator
    var store:NSPersistentStore?
    
    let debug = 1
    //MARK: FILES
    //文件名称
    let storeFilename = "CCYweather.sqlite"
    //MARK: PATHS
    private func applicationDocumentDirectory() -> String{
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last as String
    }
    
    private func applicationStroeDirectory() -> NSURL?{
        let storesDirectory = NSURL(fileURLWithPath: self.applicationDocumentDirectory())?.URLByAppendingPathComponent("Stores")
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(storesDirectory!.path!) {
            var error:NSError?
            if fileManager.createDirectoryAtURL(storesDirectory!,
                                                withIntermediateDirectories: true,
                                                attributes: nil,
                                                error: &error) {
                if debug == 1 {
                    println("Successfully created Stores directory")
                } else {
                    println("FAILED to create Stores directory:\(error!)")
                }
            }
        }
        return storesDirectory
    }
    
    private func storeURL() -> NSURL?{
        return self.applicationStroeDirectory()?.URLByAppendingPathComponent(storeFilename)
    }
    
    //MARK: SETUP
    
    override init() {
        self.model = NSManagedObjectModel.mergedModelFromBundles(nil)!
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        super.init()
    }
    
    private func loadStore(){
        if store != nil {
            return
        }
        var error:NSError?
        let options = [NSSQLitePragmasOption:["journal_model":"DELETE"]]
        store = self.coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                            configuration: nil,
                                                            URL: self.storeURL(),
                                                            options: options,
                                                            error: &error)
        if store == nil {
            println("Failed to add store.error:\(error)")
            abort()
        } else {
            if debug == 1 {
                println("Successfully added store:\(store)")
            }
        }
    }
    
    public func setupCoreData() {
        if debug == 1 {
            println("Running \(self)")
        }
        self.loadStore()
    }
    
    public func saveContext(){
        if context.hasChanges {
            var error:NSError?
            if context.save(&error) {
                println("context SAVED changes to persistent store")
            } else {
                println("Failed to save context:\(error)")
            }
        } else {
            println("SKIPPED context save.there are no changes!")
        }
    }
}
