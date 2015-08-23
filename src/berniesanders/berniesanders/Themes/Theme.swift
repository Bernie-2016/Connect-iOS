import UIKit


public protocol Theme {
    
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
    
    // MARK: Organize
    
    func organizeFeedTitleFont() -> UIFont;
    func organizeFeedTitleColor() -> UIColor;
    func organizeFeedDateFont() -> UIFont;
    func organizeFeedDateColor() -> UIColor;
    func organizeFeedHeaderBackgroundColor() -> UIColor;
    func organizeFeedHeaderTextColor() -> UIColor;
    func organizeFeedHeaderFont() -> UIFont;
}