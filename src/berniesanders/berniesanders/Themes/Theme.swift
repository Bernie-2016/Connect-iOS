import UIKit


public protocol Theme {

    // MARK: Global
    
    func defaultBackgroundColor() -> UIColor
    
    // MARK: Tab Bar
    
    func tabBarTintColor() -> UIColor
    func tabBarTextColor() -> UIColor
    func tabBarFont() -> UIFont
    
    // MARK: Navigation Bar
    
    func navigationBarBackgroundColor() -> UIColor
    func navigationBarFont() -> UIFont
    func navigationBarTextColor() -> UIColor
 
    // MARK: News Feed
    
    func newsFeedTitleFont() -> UIFont
    func newsFeedTitleColor() -> UIColor
    func newsFeedDateFont() -> UIFont
    func newsFeedDateColor() -> UIColor
    
    // MARK: Issues
    
    func issuesFeedTitleFont() -> UIFont;
    func issuesFeedTitleColor() -> UIColor;
    
    // MARK: Connect
    
    func connectFeedTitleFont() -> UIFont;
    func connectFeedTitleColor() -> UIColor;
    func connectFeedDateFont() -> UIFont;
    func connectFeedDateColor() -> UIColor;

    // MARK: feed header
    
    func feedHeaderBackgroundColor() -> UIColor;
    func feedHeaderTextColor() -> UIColor;
    func feedHeaderFont() -> UIFont;
    
    // MARK: News Item detail screen
    
    func newsItemDateFont() -> UIFont;
    func newsItemDateColor() -> UIColor;
    func newsItemTitleFont() -> UIFont;
    func newsItemTitleColor() -> UIColor;
    func newsItemBodyFont() -> UIFont;
    func newsItemBodyColor() -> UIColor;

}