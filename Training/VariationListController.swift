import UIKit

class VariationListController: BaseController {
    
    var variations = [Variation]()
    
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
        
        if variation.valueForKey("video") == nil {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let variation = variations[indexPath.row]
        if let video = variation.valueForKey("video") as String! {
            if let url = NSURL(string: "http://www.youtube.com/watch?v=\(video)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

    class func forVariations(variations: [Variation]) -> VariationListController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("VariationListController") as VariationListController
        controller.variations = variations
        return controller
    }
    
}
