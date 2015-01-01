import UIKit

class ExerciseController: UIViewController {
    
    var exercise: Exercise? = nil
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var varsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = exercise?.name
        if let image: String = exercise?.category.image as String! {
            categoryImage.image = UIImage(named: image)
        }
        categoryLabel.text = "Categorie: \(exercise!.category.name)"

        textLabel.text = exercise?.text
        textLabel.sizeToFit()
        
        if let vars: String = exercise?.valueForKey("variations") as String! {
            if ( vars != "" ) {
                let comps = vars.componentsSeparatedByString(";") as NSArray
                varsLabel.text = "Variaties:\n• " + comps.componentsJoinedByString("\n• ")
            }
            else {
                varsLabel.text = "Geen variaties."
            }
        }
        else {
            varsLabel.text = "Geen variaties."
        }
    }
    
    class func forExercise(exercise: Exercise) -> ExerciseController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ExerciseController") as ExerciseController
        controller.exercise = exercise
        return controller
    }
}
