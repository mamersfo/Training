import UIKit
import CoreData

class TrainingController: BaseController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var user: NSDictionary?
    var training: NSDictionary?
    var exercises = [Exercise]()
    var searchController: UISearchController!
    var resultsController: ExerciseListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = training?.objectForKey("name") as? String
        
        resultsController = ExerciseListController()
        resultsController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)

        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        
        // prevent content being visible above the search bar
        definesPresentationContext = true

        if let array = self.training?.objectForKey("exercises") as? NSArray {
            let fr = NSFetchRequest(entityName: "Exercise")
            let lhs = NSExpression(forKeyPath: "uuid")
            let rhs = NSExpression(forConstantValue: array)
            fr.predicate = NSComparisonPredicate(
                leftExpression: lhs, rightExpression: rhs,
                modifier: .DirectPredicateModifier,
                type: .InPredicateOperatorType,
                options: .CaseInsensitivePredicateOption)
            var error: NSError? = nil
            if let fetchResults = self.managedObjectContext!.executeFetchRequest(fr, error: &error) as? [Exercise] {
                self.exercises = fetchResults
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell
        
        if let exercise: Exercise = exercises[indexPath.row] as Exercise! {
            cell.textLabel?.text = exercise.name
            
            if let image: String = exercise.category.image as String! {
                cell.imageView?.image = UIImage(named: image)
            }
            
            cell.showsReorderControl = true
        }
        return cell
    }
    
    func update(exercises: [Exercise]) {
        var requestBody = Dictionary<String,AnyObject>()
        requestBody["exercises"] = exercises.map{ ( exercise: Exercise ) -> String in
            return exercise.uuid
        }

        if let userId = self.user?.objectForKey("id") as? Int {
            if let trainingId: AnyObject = self.training?.objectForKey("id") {
                Client.putRequest(
                    "\(Constants.baseUrl)/users/\(userId)/trainings/\(trainingId)",
                    body: requestBody,
                    handler: { status, responseBody -> Void in
                        if ( status == 201 ) {
                            self.exercises = exercises
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        }
                        else {
                            AppDelegate.showErrorMessage(responseBody?.objectForKey("message") as String,
                                viewController: self)
                        }
                    })
            }
            else {
                AppDelegate.showErrorMessage("Training id is undefined", viewController: self)
            }
        }
        else {
            AppDelegate.showErrorMessage("User id is undefined", viewController: self)
        }
    }
    
    func copyExercises() -> [Exercise] {
        var copy = [Exercise]()
        for e in self.exercises {
            copy.append(e)
        }
        return copy
    }
    
    // add
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView === self.tableView) {
            if let exercise: Exercise = exercises[indexPath.row] as Exercise! {
                let controller = ExerciseController.forExercise(exercise)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
        else if (tableView == resultsController.tableView) {
            if let exercise: Exercise = resultsController.exercises[indexPath.row] as Exercise! {
                var copy = self.copyExercises()
                copy.append(exercise)
                self.update(copy)
            }
            
            searchController.active = false
        }
    }
    
    // move
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let tmp = exercises[sourceIndexPath.item]
        var copy = self.copyExercises()
        copy[sourceIndexPath.item] = copy[destinationIndexPath.item]
        copy[destinationIndexPath.item] = tmp
        self.update(copy)
    }
    
    // delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            var copy = self.copyExercises()
            copy.removeAtIndex(indexPath.row)
            self.update(copy)
        }
    }

    class func forTraining(training: NSDictionary, user: NSDictionary) -> TrainingController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TrainingController") as TrainingController
        controller.user = user
        controller.training = training
        return controller
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var andMatchPredicates = [NSPredicate]()

        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .NoStyle
        numberFormatter.formatterBehavior = .BehaviorDefault

        for searchString in searchItems {
            
            let targetNumber = numberFormatter.numberFromString(searchString)

            if targetNumber != nil {
                let lhs = NSExpression(forKeyPath: "station")
                let rhs = NSExpression(forConstantValue: targetNumber!)
                
                andMatchPredicates.append(
                    NSComparisonPredicate(
                        leftExpression: lhs, rightExpression: rhs,
                        modifier: .DirectPredicateModifier,
                        type: .EqualToPredicateOperatorType,
                        options: .CaseInsensitivePredicateOption))
            }
            else {
                var lhs1 = NSExpression(forKeyPath: "name")
                var lhs2 = NSExpression(forKeyPath: "tags")
                var rhs = NSExpression(forConstantValue: searchString)
                
                andMatchPredicates.append(
                    NSCompoundPredicate.orPredicateWithSubpredicates([
                        NSComparisonPredicate(
                            leftExpression: lhs1, rightExpression: rhs,
                            modifier: .DirectPredicateModifier,
                            type: .ContainsPredicateOperatorType,
                            options: .CaseInsensitivePredicateOption),
                        NSComparisonPredicate(
                            leftExpression: lhs2, rightExpression: rhs,
                            modifier: .DirectPredicateModifier,
                            type: .ContainsPredicateOperatorType,
                            options: .CaseInsensitivePredicateOption),
                        ])
                    )
            }
        }
        
        let finalCompoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(andMatchPredicates)
        
        let fr = NSFetchRequest(entityName: "Exercise")
        fr.predicate = finalCompoundPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fr.sortDescriptors = [sortDescriptor]
        
        var error: NSError? = nil
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fr, error: &error) as? [Exercise] {
            let controller = searchController.searchResultsController as ExerciseListController
            controller.exercises = fetchResults
            controller.tableView.reloadData()
        }
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