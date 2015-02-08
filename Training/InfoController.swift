import UIKit

class InfoController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = self.contentView.bounds.size
        self.contentView.frame = CGRectMake(0, 0, size.width, size.height)
        self.scrollView.contentSize = size;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("CurrentViewController", object: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let orientation = UIDevice.currentDevice().valueForKey("orientation") as NSNumber
        
        if ( orientation != UIInterfaceOrientation.Portrait.rawValue ) {
            UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.Portrait.rawValue), forKey:"orientation")
        }
    }
}
