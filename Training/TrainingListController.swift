import UIKit
import CoreData

class TrainingListController: BaseController, UIAlertViewDelegate {
    
    var trainings = [Training]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    func reload() {
        let fr = NSFetchRequest(entityName: "Training")
        var error: NSError? = nil
        if let fetchResults = managedObjectContext!.executeFetchRequest(fr, error: &error) as? [Training] {
            self.trainings = fetchResults
            self.tableView.reloadData()
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
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if ( buttonIndex == 1 ) {
            if let textField = alertView.textFieldAtIndex(0) {
                Training.create(managedObjectContext!, name: textField.text)
                reload()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell
        let training: Training = trainings[indexPath.row] as Training
        cell.textLabel?.text = training.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let training = trainings[indexPath.row]
        let trainingController = TrainingController.forTraining(training)
        navigationController?.pushViewController(trainingController, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            managedObjectContext!.deleteObject(trainings[indexPath.row])
            managedObjectContext!.save(nil)
            trainings.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
