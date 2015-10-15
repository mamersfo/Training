import UIKit
import CoreData

class TrainingListController: BaseController, UIAlertViewDelegate {
    var trainings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trainings = Repository.read("trainings")
        self.tableView.reloadData()
    }
    
    @IBAction func add(sender: AnyObject) {
        let prompt = UIAlertView(
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
                if let training = textField.text {
                    self.trainings.append(training)
                    Repository.update("trainings", value: self.trainings)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell!
        cell.textLabel?.text = trainings[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let training = trainings[indexPath.row]
        let trainingController = TrainingController.forTraining(training)
        self.navigationController?.pushViewController(trainingController, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            trainings.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath],
                withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
