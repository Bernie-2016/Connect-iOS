import UIKit


public protocol Theme {

    // MARK: Global
    
    func defaultBackgroundColor() -> UIColor
    
    // MARK: Tab Bar
    
    func tabBarTintColor() -> UIColor
    func tabBarActiveTextColor() -> UIColor
    func tabBarInactiveTextColor() -> UIColor
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
    func newsFeedHeadlineTitleFont() -> UIFont
    func newsfeedHeadlineTitleColor() -> UIColor
    func newsFeedHeadlineTitleBackgroundColor() -> UIColor
    
    // MARK: Issues
    
    func issuesFeedTitleFont() -> UIFont
    func issuesFeedTitleColor() -> UIColor
    
    // MARK: feed header
    
    func feedHeaderBackgroundColor() -> UIColor
    func feedHeaderTextColor() -> UIColor
    func feedHeaderFont() -> UIFont
    
    // MARK: News Item detail screen
    
    func newsItemDateFont() -> UIFont
    func newsItemDateColor() -> UIColor
    func newsItemTitleFont() -> UIFont
    func newsItemTitleColor() -> UIColor
    func newsItemBodyFont() -> UIFont
    func newsItemBodyColor() -> UIColor
    
    // MARK: Issue detail screen
    
    func issueTitleFont() -> UIFont
    func issueTitleColor() -> UIColor
    func issueBodyFont() -> UIFont
    func issueBodyColor() -> UIColor
    
    // MARK: Connect screen
    
    func connectListFont() -> UIFont
    func connectListColor() -> UIColor
    func connectGoButtonFont() -> UIFont
    func connectGoButtonTextColor() -> UIColor
    func connectGoButtonBackgroundColor() -> UIColor
    func connectGoButtonCornerRadius() -> CGFloat
    func connectZipCodeTextColor() -> UIColor
    func connectZipCodeBackgroundColor() -> UIColor
    func connectZipCodeBorderColor() -> UIColor
    func connectZipCodeFont() -> UIFont
    func connectZipCodeCornerRadius() -> CGFloat
    func connectZipCodeBorderWidth() -> CGFloat
    func connectZipCodeTextOffset() -> CATransform3D
    func connectNoResultsTextColor() -> UIColor
    func connectNoResultsFont() -> UIFont
    
    // MARK: Settings
    
    func settingsTitleFont() -> UIFont
    func settingsTitleColor() -> UIColor
}