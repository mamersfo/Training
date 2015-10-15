import UIKit

class ExerciseController: UIViewController {
    
    var exercise: Exercise? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var varsLabel: UILabel!
    @IBOutlet weak var diagramImage: UIImageView!
    
    func variationsAsText(variations: NSOrderedSet) -> NSAttributedString {
        
        let mas = NSMutableAttributedString()
        mas.appendAttributedString(NSAttributedString(string: "Varianten:\n",
            attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17.0)]))
        
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(14.0)]

        let bullet = NSAttributedString(string: "• ", attributes: attrs)
        let newline = NSAttributedString(string: "\n", attributes: attrs)
        
        for i in 0...variations.count-1 {
            mas.appendAttributedString(bullet)
            let variation = variations.objectAtIndex(i) as! Variation
            let name = NSAttributedString(string: variation.name, attributes: attrs)
            mas.appendAttributedString(name)
            
            if let video = variation.valueForKey("video") as? String {
                mas.addAttribute(NSLinkAttributeName,
                    value: "http://www.youtube.com/watch?v=\(video)",
                    range: NSMakeRange(mas.length-name.length, name.length))
            }
            
            if let comment = variation.valueForKey("comment") as? String {
                mas.appendAttributedString(
                    NSAttributedString(string: ", \(comment)", attributes: attrs))
            }
            
            if let source = variation.valueForKey("source") as? String {
                mas.appendAttributedString(
                    NSAttributedString(string: " [\(source)]", attributes: attrs))
            }
            
            mas.appendAttributedString(newline)
        }
        
        let range = NSMakeRange(0,mas.length)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        mas.addAttribute(NSParagraphStyleAttributeName, value: style, range: range)
        
        return mas
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = exercise?.name
        
        if let image: String = exercise?.category.image as String! {
            categoryImage.image = UIImage(named: image)
        }
        
        categoryLabel.text = "Categorie: \(exercise!.category.name)"

        textLabel.text = exercise?.text
        
        if let uuid = exercise?.uuid as String! {
            if let image = UIImage(named: uuid) {
                diagramImage.image = image
            }
        }
        
//        for e in exercise!.variations.array {
//            println("exercise: \(e.name)")
//        }
        
        navigationItem.rightBarButtonItem!.enabled = exercise!.variations.count > 0
    }
    
    override func viewDidLayoutSubviews() {
        let size = CGSizeMake(
            contentView.bounds.size.width,
            diagramImage.center.y + diagramImage.bounds.height/2 + 8
        )
        
        contentView.frame = CGRectMake(0, 0, size.width, size.height)
        
        self.scrollView.contentSize = size;
    }
    
    class func forExercise(exercise: Exercise) -> ExerciseController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ExerciseController") as! ExerciseController
        controller.exercise = exercise
        return controller
    }
    
    @IBAction func more(sender: AnyObject) {
        if let vars = exercise?.variations.array as? [Variation] {
            let controller = VariationListController.forVariations(vars)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentViewController", object: self)
    }    
}
