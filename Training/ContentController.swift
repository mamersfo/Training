import UIKit

class ContentController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = self.contentView.bounds.size
        self.contentView.frame = CGRectMake(0, 0, size.width, size.height)
        self.scrollView.contentSize = size;
        self.contentView = nil;
    }    
}