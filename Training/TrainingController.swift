import UIKit
import CoreData

class TrainingController: BaseController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var training: Training!
    var searchController: UISearchController!
    var resultsController: ExerciseListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = training.name
        
        resultsController = ExerciseListController()
        resultsController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)

        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true

        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = false
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return training!.exercises.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell
        if let trainingExercise: TrainingExercise = training?.exercises[indexPath.row] as TrainingExercise! {
            cell.textLabel?.text = trainingExercise.exercise.name
            
            if let image: String = trainingExercise.exercise.category.image as String! {
                cell.imageView?.image = UIImage(named: image)
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView === self.tableView) {
            if let trainingExercise: TrainingExercise = training?.exercises[indexPath.row] as TrainingExercise! {
                let controller = ExerciseController.forExercise(trainingExercise.exercise)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
        else if (tableView == resultsController.tableView) {
            if let exercise: Exercise = resultsController.exercises[indexPath.row] as Exercise! {
                let trainingExercise = TrainingExercise.create(
                    managedObjectContext!, training: training, exercise: exercise)
                
                training!.willChangeValueForKey("exercises")
                training!.mutableOrderedSetValueForKey("exercises").addObject(trainingExercise)
                training!.didChangeValueForKey("exercises")
                
                managedObjectContext!.save(nil)
                self.tableView.reloadData()
            }
            
            searchController.active = false
        }
    }
    
    class func forTraining(training: Training) -> TrainingController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TrainingController") as TrainingController
        controller.training = training
        return controller
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let exercises = training!.mutableOrderedSetValueForKey("exercises")
            let trainingExercise = exercises[indexPath.row] as TrainingExercise
            
            training?.willChangeValueForKey("exercises")
            exercises.removeObjectAtIndex(indexPath.row)
            training?.didChangeValueForKey("exercises")
            
            managedObjectContext?.deleteObject(trainingExercise)

            var error: NSError? = nil
            if ( managedObjectContext!.save(&error) ) {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                NSLog("Error: \(error)")
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var andMatchPredicates = [NSPredicate]()
        
        for searchString in searchItems {
            
            var lhs = NSExpression(forKeyPath: "name")
            var rhs = NSExpression(forConstantValue: searchString)
            
            var finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            andMatchPredicates.append(finalPredicate)
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
}