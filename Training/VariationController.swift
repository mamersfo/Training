import UIKit

class VariationController: UIViewController {
    
    var variation: Variation!
    @IBOutlet weak var webView: UIWebView!

    private func toURL(variation: Variation) -> NSURL? {
        if let video = variation.valueForKey("video") as? String {
            if let time = variation.valueForKey("time") as? String {
                return NSURL(string: "http://www.youtube.com/watch?v=\(video)&t=\(time)")!
            }
            else {
                return NSURL(string: "http://www.youtube.com/watch?v=\(video)")!
            }
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = variation.name
        
        if let url = toURL(variation) as NSURL? {
            webView.loadRequest(NSURLRequest(URL: url))
        }
        
        self
    }

    class func forVariation(variation: Variation) -> VariationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("VariationController") as! VariationController
        controller.variation = variation
        return controller
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentViewController", object: self)
        UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.LandscapeRight.rawValue), forKey:"orientation")
    }    
}
