//
//  AppDelegate.swift
//  Consulta Persistente ISBN
//
//  Created by Francisco Betancourt on 13/03/2016.
//  Copyright © 2016 Francisco Betancourt. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   var window: UIWindow?

   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

      return true
   }

   func applicationWillResignActive(application: UIApplication) {
   }

   func applicationDidEnterBackground(application: UIApplication) {
   }

   func applicationWillEnterForeground(application: UIApplication) {
   }

   func applicationDidBecomeActive(application: UIApplication) {
   }

   func applicationWillTerminate(application: UIApplication) {
   }

   // MARK: - Core Data Stack

   lazy var applicationDocumentsDirectory: NSURL = {

      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      return urls[urls.count - 1]
   }()

   lazy var managedObjectModel: NSManagedObjectModel = {

      let modelURL = NSBundle.mainBundle().URLForResource("BookModel", withExtension: "momd")!
      return NSManagedObjectModel(contentsOfURL: modelURL)!
   }()

   lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

      let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Books.sqlite")

      do {

         try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)

      } catch {

         NSLog("persistentStoreCoordinator: Error!")
      }

      return coordinator
   }()

   lazy var managedObjectContext: NSManagedObjectContext = {

      var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
      managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

      return managedObjectContext
   }()
}