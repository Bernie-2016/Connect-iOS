import UIKit


public protocol Theme {
    
    // MARK: Tab Bar
    
    func tabBarTintColor() -> UIColor
    func tabBarTextColor() -> UIColor
    func tabBarFont() -> UIFont
    
    //MARK: Navigation Bar
    
    func navigationBarBackgroundColor() -> UIColor
    func navigationBarFont() -> UIFont
    func navigationBarTextColor() -> UIColor
 
    //MARK: News Feed
    
    func newsFeedTitleFont() -> UIFont
    func newsFeedTitleColor() -> UIColor
    func newsFeedDateFont() -> UIFont
    func newsFeedDateColor() -> UIColor
    
}