import UIKit


public protocol Theme {

    // MARK: Global
    
    func defaultBackgroundColor() -> UIColor
    func defaultSpinnerColor() -> UIColor
    func attributionFont() -> UIFont
    func attributionTextColor() -> UIColor
    func defaultButtonBackgroundColor() -> UIColor
    func defaultButtonTextColor() -> UIColor
    func defaultButtonFont() -> UIFont

    
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
    
    // MARK: Events screen
    
    func eventsListFont() -> UIFont
    func eventsListColor() -> UIColor
    func eventsInputAccessoryBackgroundColor() -> UIColor
    func eventsZipCodeTextColor() -> UIColor
    func eventsZipCodeBackgroundColor() -> UIColor
    func eventsZipCodeBorderColor() -> UIColor
    func eventsZipCodeFont() -> UIFont
    func eventsZipCodeCornerRadius() -> CGFloat
    func eventsZipCodeBorderWidth() -> CGFloat
    func eventsZipCodeTextOffset() -> CATransform3D
    func eventsNoResultsTextColor() -> UIColor
    func eventsNoResultsFont() -> UIFont
    func eventsInstructionsFont() -> UIFont
    func eventsInstructionsTextColor() -> UIColor
    
    // MARK: Event screen
    
    func eventDirectionsButtonBackgroundColor() -> UIColor
    func eventRSVPButtonBackgroundColor() -> UIColor
    func eventButtonTextColor() -> UIColor
    func eventDirectionsButtonFont() -> UIFont
    func eventNameFont() -> UIFont
    func eventNameColor() -> UIColor
    func eventStartDateFont() -> UIFont
    func eventStartDateColor() -> UIColor
    func eventAttendeesFont() -> UIFont
    func eventAttendeesColor() -> UIColor
    func eventAddressFont() -> UIFont
    func eventAddressColor() -> UIColor
    func eventDescriptionHeadingFont() -> UIFont
    func eventDescriptionHeadingColor() -> UIColor
    func eventDescriptionFont() -> UIFont
    func eventDescriptionColor() -> UIColor
    
    // MARK: Settings
    
    func settingsTitleFont() -> UIFont
    func settingsTitleColor() -> UIColor
    
    // MARK: About
    
    func aboutButtonBackgroundColor() -> UIColor
    func aboutButtonTextColor() -> UIColor
    func aboutButtonFont() -> UIFont
    func aboutBodyTextFont() -> UIFont

    // MARK: Welcome 
    
    func welcomeLabelFont() -> UIFont
    func viewPolicyBackgroundColor() -> UIColor
    
}