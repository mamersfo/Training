import UIKit
import CoreData

class BaseController: UITableViewController {

    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cellID")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func edit(sender: AnyObject) {
        if tableView.editing {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else {            
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
}
