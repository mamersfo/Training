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

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Exercises", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Exercises.sqlite")
        
        println("url: \(url)")
        
        var error: NSError? = nil
        
        let fm = NSFileManager.defaultManager()
        
        if ( fm.fileExistsAtPath(url.path!) ) {
            
            if let dir = url.URLByDeletingLastPathComponent as NSURL! {
                
                let contents = fm.contentsOfDirectoryAtPath(dir.path!, error: &error) as [String]
                
                for next in contents {
                    if next.hasPrefix("Exercises") {
                        let nexturl = dir.URLByAppendingPathComponent(next)
                        if (!fm.removeItemAtURL(nexturl, error: &error)) {
                            println("Error deleting file: \(error)")
                        }
                    }
                }
            }
        }

        if let preloadURL = NSBundle.mainBundle().URLForResource("Exercises", withExtension: "sqlite") {
            if (!fm.copyItemAtURL( preloadURL, toURL: url, error: &error)) {
                println("Unable to copy \(preloadURL) to \(url)")
            }
        }
        
        if coordinator!.addPersistentStoreWithType(
            NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}

