import UIKit

class VariationListController: BaseController {
    
    var variations = [Variation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "More"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as UITableViewCell
        
        let variation = variations[indexPath.row] as Variation!
        cell.textLabel?.text = variation.name
        
        if let source = variation.valueForKey("source") as? String {
            cell.imageView?.image = UIImage(named: source)
        }
        else {
            cell.imageView?.image = UIImage(named: "empty")
        }
        
        if variation.valueForKey("video") == nil {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let let variation = variations[indexPath.row] as Variation? {
            let controller = VariationController.forVariation(variation)
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    class func forVariations(variations: [Variation]) -> VariationListController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("VariationListController") as VariationListController
        controller.variations = variations
        return controller
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let orientation = UIDevice.currentDevice().valueForKey("orientation") as NSNumber
        
        if ( orientation != UIInterfaceOrientation.Portrait.rawValue ) {
            UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.Portrait.rawValue), forKey:"orientation")
        }
    }
}
