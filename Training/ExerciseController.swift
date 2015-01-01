import UIKit

class ExerciseController: UIViewController {
    
    var exercise: Exercise? = nil
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = exercise?.name
        textLabel.text = exercise?.text        
    }
    
    class func forExercise(exercise: Exercise) -> ExerciseController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ExerciseController") as ExerciseController
        controller.exercise = exercise
        return controller
    }
}
