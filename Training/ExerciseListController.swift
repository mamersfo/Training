import UIKit

class ExerciseListController: UITableViewController, UITableViewDataSource {
    
    var exercises = [Exercise]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let exercise = exercises[indexPath.row]
        
        cell.textLabel?.text = exercise.name
        
        if let image: String = exercise.category.image as String! {
            cell.imageView?.image = UIImage(named: image)
        }
        
        return cell
    }
}