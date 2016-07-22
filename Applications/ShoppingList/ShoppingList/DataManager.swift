//
//  DataManager.swift
//  ShoppingList
//
//  Created by Yijia Xu on 7/6/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import CoreData

class DataManager {
    
    // I used to use singleton here, but it seems it is better that use dependence injection.
    internal init() {
        setupCoreDataStack()
    }

    
    var managedObjectModel: NSManagedObjectModel?
//        = {
//        let modelURL = NSBundle.mainBundle().URLForResource("ShoppingListModel", withExtension: "momd")
//        return NSManagedObjectModel(contentsOfURL: modelURL!)!
//    }()
//    
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? /*= {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let storePath = paths[0]
        let storeURL = NSURL(fileURLWithPath: storePath.stringByAppendingString("ShoppingListModel.sqlite"))
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            coordinator = nil
            abort()
        }
        
        return coordinator
    }()*/
    
    var mainContext: NSManagedObjectContext?
    
    
    func setupCoreDataStack() {
        let modelURL = NSBundle.mainBundle().URLForResource("ShoppingListModel", withExtension: "momd")
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let storePath = paths[0]
        let storeURL = NSURL(fileURLWithPath: storePath.stringByAppendingString("ShoppingListModel.sqlite"))
        
        do {
            try persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            persistentStoreCoordinator = nil
            abort()
        }
        
        mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext?.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    
    func saveContext() {
        guard let mainContext = mainContext else { return }
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                print("Error: \(nserror.localizedDescription)")
                abort()
            }
        }
    }

    
}
