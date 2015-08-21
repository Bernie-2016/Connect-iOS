import UIKit


class DefaultTheme : Theme {
    // MARK: News Feed
    
    func newsFeedTitleColor() -> UIColor {
        return UIColor.grayColor()
    }
    
    func newsFeedTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(14.0);
    }
    
    func newsFeedDateColor() -> UIColor {
        return UIColor.redColor()
    }
    
    func newsFeedDateFont() -> UIFont {
        return UIFont.systemFontOfSize(12.0)
    }
}
