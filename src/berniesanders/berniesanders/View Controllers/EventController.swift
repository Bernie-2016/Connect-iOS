import UIKit

public class EventController : UIViewController {
    public let event : Event!
    public let dateFormatter : NSDateFormatter!
    public let theme : Theme!
    
    public init(
        event: Event,
        dateFormatter: NSDateFormatter,
        theme: Theme) {
            
            self.event = event
            self.dateFormatter = dateFormatter
            self.theme = theme
            
            super.init(nibName: nil, bundle: nil)
            
            //            self.hidesBottomBarWhenPushed = true
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
