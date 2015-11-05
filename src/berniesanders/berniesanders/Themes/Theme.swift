import UIKit


protocol Theme {

    // MARK: Global

    func defaultBackgroundColor() -> UIColor
    func defaultSpinnerColor() -> UIColor
    func attributionFont() -> UIFont
    func attributionTextColor() -> UIColor
    func defaultButtonBackgroundColor() -> UIColor
    func defaultButtonTextColor() -> UIColor
    func defaultButtonFont() -> UIFont
    func defaultDisclosureColor() -> UIColor
    func highlightDisclosureColor() -> UIColor

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

    func newsFeedBackgroundColor() -> UIColor
    func newsFeedTitleFont() -> UIFont
    func newsFeedTitleColor() -> UIColor
    func newsFeedExcerptFont() -> UIFont
    func newsFeedExcerptColor() -> UIColor
    func newsFeedDateFont() -> UIFont
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

    func eventsListNameFont() -> UIFont
    func eventsListNameColor() -> UIColor
    func eventsListDistanceFont() -> UIFont
    func eventsListDistanceColor() -> UIColor
    func eventsListDistanceTodayColor() -> UIColor
    func eventsListDateFont() -> UIFont
    func eventsListDateColor() -> UIColor
    func eventsListDateTodayColor() -> UIColor
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
    func settingsDonateButtonFont() -> UIFont
    func settingsDonateButtonColor() -> UIColor
    func settingsDonateButtonTextColor() -> UIColor
    func settingsAnalyticsFont() -> UIFont

    // MARK: About

    func aboutButtonBackgroundColor() -> UIColor
    func aboutButtonTextColor() -> UIColor
    func aboutButtonFont() -> UIFont
    func aboutBodyTextFont() -> UIFont

    // MARK: Welcome

    func welcomeLabelFont() -> UIFont
    func viewPolicyBackgroundColor() -> UIColor
    func agreeToTermsLabelFont() -> UIFont

}
