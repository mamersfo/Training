import UIKit
import CoreData

class TrainingListController: BaseController, UIAlertViewDelegate {
    
    var trainings = [NSDictionary]()
    var user: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = NSUserDefaults.standardUserDefaults()
        
        var body = Dictionary<String,AnyObject>()
        body["username"] = settings.stringForKey("username")
        body["password"] = settings.stringForKey("password")
        
        Client.postRequest(
            "\(Constants.baseUrl)/login",
            body: body,
            handler: { status, body -> Void in
                
                if status == 200 {
                    self.user = body as? NSDictionary
                    self.reload()
                }
                else if let dict = body as? NSDictionary {
                    if let message: AnyObject = body?.objectForKey("message") {
                        self.showErrorMessage("\(message)")
                    }
                }
        })
    }
    
    func reload() {
        if let id = self.user?.objectForKey("id") as? Int {
            Client.getRequest(
                "\(Constants.baseUrl)/users/\(id)/trainings",
                handler: { status, body -> Void in
                    self.trainings = body as [NSDictionary]
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
            })
        }
    }
    
    @IBAction func add(sender: AnyObject) {
        var prompt = UIAlertView(
            title: "Add Training",
            message: "Please enter a name",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Add")
        
        prompt.alertViewStyle = .PlainTextInput
        prompt.show()
    }
    
    func showErrorMessage(message: String) {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if ( buttonIndex == 1 ) {
            if let textField = alertView.textFieldAtIndex(0) {
                
                if let id = self.user?.objectForKey("id") as? Int {
                    var body = Dictionary<String,AnyObject>()
                    body["name"] = textField.text
                    
                    Client.postRequest(
                        "\(Constants.baseUrl)/users/\(id)/trainings",
                        body: body,
                        handler: { status, result -> Void in
                            if let dict = result as? NSDictionary {
                                if let message: AnyObject = dict.objectForKey("message") {
                                    self.showErrorMessage(message as String)
                                }
                                else {
                                    self.trainings.append(result as NSDictionary)
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                    })
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell
        let training = trainings[indexPath.row] as NSDictionary
        cell.textLabel?.text = training.objectForKey("name") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let training = trainings[indexPath.row] as NSDictionary
        
        let userId = self.user?.objectForKey("id") as? Int
        let trainingId: AnyObject = training.objectForKey("id")!
        
        Client.getRequest(
            "\(Constants.baseUrl)/users/\(userId)/trainings/\(trainingId)",
            handler: { status, body -> Void in
                if let dict = body as? NSDictionary {
                    dispatch_async(dispatch_get_main_queue()) {
                        let trainingController = TrainingController.forTraining(dict, user: self.user!)
                        self.navigationController?.pushViewController(trainingController, animated: true)
                    }
                }
        })
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let userId = self.user?.objectForKey("id") as? Int {
                let training = trainings[indexPath.row] as NSDictionary
                if let trainingId: AnyObject = training.objectForKey("id") {
                    Client.deleteRequest(
                        "\(Constants.baseUrl)/users/\(userId)/trainings/\(trainingId)",
                        handler: { status, body -> Void in
                            if ( status == 204 ) {
                                self.trainings.removeAtIndex(indexPath.row)
                                dispatch_async(dispatch_get_main_queue()) {
                                    tableView.deleteRowsAtIndexPaths([indexPath],
                                        withRowAnimation: UITableViewRowAnimation.Automatic)
                                }
                            }
                            else if let dict = body as? NSDictionary {
                                self.showErrorMessage(dict.objectForKey("message") as String)
                            }
                        })
                }
                else {
                    self.showErrorMessage("Training id is undefined")
                }
            }
            else {
                self.showErrorMessage("User id is undefined")
            }
        }
    }
}
