import UIKit

public class NewsItemController : UIViewController {
    private(set) public var newsItem : NewsItem!
    
    public init(newsItem: NewsItem) {
        self.newsItem = newsItem
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        self.view.backgroundColor = UIColor.whiteColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
