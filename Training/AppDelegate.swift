import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentViewController: UIViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: "handler:", name: "CurrentViewController", object: nil)
        
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
    
    func handler(notification: NSNotification) {
        if let found = notification.object as UIViewController? {
            self.currentViewController = found
        }
    }
    
    func application(application: UIApplication,supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int {
        
        if self.currentViewController is VariationController {
            return Int( UIInterfaceOrientationMask.LandscapeRight.rawValue )
        }
        else {
            return Int( UIInterfaceOrientationMask.Portrait.rawValue );
        }
    }
    
    class func showErrorMessage(message: String, viewController: UIViewController) {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        controller.addAction(cancelAction)
        viewController.presentViewController(controller, animated: true, completion: nil)
    }
}

