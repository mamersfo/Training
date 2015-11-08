import UIKit
import CoreData

class TrainingController: BaseController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var training: String = ""
    var exercises = [Exercise]()
    var searchController: UISearchController!
    var resultsController: ExerciseListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = training
        
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
        
        if let array = Repository.read(training) as [String]? {
            let fr = NSFetchRequest(entityName: "Exercise")
            let lhs = NSExpression(forKeyPath: "uuid")
            let rhs = NSExpression(forConstantValue: array)
            fr.predicate = NSComparisonPredicate(
                leftExpression: lhs, rightExpression: rhs,
                modifier: .DirectPredicateModifier,
                type: .InPredicateOperatorType,
                options: .CaseInsensitivePredicateOption)
            
            do {
                if let fetchResults = try self.managedObjectContext!.executeFetchRequest(fr) as? [Exercise] {
                    
                    // create a dictionary from the fetch results
                    let dict = fetchResults.reduce([String:Exercise]()) { (var d, e) in
                        d[e.uuid] = e
                        return d
                    }
                    
                    // create array of exercises using the order of the stored uuids
                    self.exercises = array.map{ ( uuid: String ) -> Exercise in
                        return dict[uuid]!
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell!
        
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
        
        let uuids = exercises.map{ ( exercise: Exercise ) -> String in
            return exercise.uuid
        }
        
        print("update: \(uuids)")

        Repository.update(training, value: uuids)
        self.exercises = exercises
        self.tableView.reloadData()
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

    class func forTraining(training: String) -> TrainingController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TrainingController") as! TrainingController
        controller.training = training
        return controller
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
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
                let lhs1 = NSExpression(forKeyPath: "name")
                let lhs2 = NSExpression(forKeyPath: "tags")
                let rhs = NSExpression(forConstantValue: searchString)
                
                andMatchPredicates.append(
                    NSCompoundPredicate(orPredicateWithSubpredicates:[
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
        
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:andMatchPredicates)
        
        let fr = NSFetchRequest(entityName: "Exercise")
        fr.predicate = finalCompoundPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fr.sortDescriptors = [sortDescriptor]
        
        do {
            if let fetchResults = try self.managedObjectContext!.executeFetchRequest(fr) as? [Exercise] {
                let controller = searchController.searchResultsController as! ExerciseListController
                controller.exercises = fetchResults
                controller.tableView.reloadData()
            }
        } catch {
            print(error)
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