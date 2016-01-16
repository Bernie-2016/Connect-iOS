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
    func newsFeedVideoOverlayBackgroundColor() -> UIColor

    // MARK: Issues

    func issuesFeedTitleFont() -> UIFont
    func issuesFeedTitleColor() -> UIColor

    // MARK: News Article detail screen

    func newsArticleDateFont() -> UIFont
    func newsArticleDateColor() -> UIColor
    func newsArticleTitleFont() -> UIFont
    func newsArticleTitleColor() -> UIColor
    func newsArticleBodyFont() -> UIFont
    func newsArticleBodyColor() -> UIColor

    // MARK: Video Article screen

    func videoDateFont() -> UIFont
    func videoDateColor() -> UIColor
    func videoTitleFont() -> UIFont
    func videoTitleColor() -> UIColor
    func videoDescriptionFont() -> UIFont
    func videoDescriptionColor() -> UIColor

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
    func defaultTableSectionHeaderFont() -> UIFont
    func defaultTableSectionHeaderTextColor() -> UIColor
    func defaultTableSectionHeaderBackgroundColor() -> UIColor
    func eventsSearchBarBackgroundColor() -> UIColor
    func eventsZipCodeTextColor() -> UIColor
    func eventsZipCodeBackgroundColor() -> UIColor
    func eventsZipCodeBorderColor() -> UIColor
    func eventsSearchBarFont() -> UIFont
    func eventsZipCodeCornerRadius() -> CGFloat
    func eventsZipCodeBorderWidth() -> CGFloat
    func eventsZipCodeTextOffset() -> CATransform3D
    func eventsInformationTextColor() -> UIColor
    func eventsNoResultsFont() -> UIFont
    func eventsCreateEventCTAFont() -> UIFont
    func eventsInstructionsFont() -> UIFont
    func eventsSubInstructionsFont() -> UIFont

    // MARK: Event screen

    func eventDirectionsButtonBackgroundColor() -> UIColor
    func eventRSVPButtonBackgroundColor() -> UIColor
    func eventRSVPButtonTextColor() -> UIColor
    func eventRSVPButtonFont() -> UIFont
    func eventDirectionsButtonTextColor() -> UIColor
    func eventDirectionsButtonFont() -> UIFont
    func eventNameFont() -> UIFont
    func eventNameColor() -> UIColor
    func eventStartDateFont() -> UIFont
    func eventStartDateColor() -> UIColor
    func eventAddressFont() -> UIFont
    func eventAddressColor() -> UIColor
    func eventDescriptionHeadingFont() -> UIFont
    func eventDescriptionHeadingColor() -> UIColor
    func eventDescriptionFont() -> UIFont
    func eventDescriptionColor() -> UIColor
    func eventBackgroundColor () -> UIColor
    func eventTypeFont() -> UIFont
    func eventTypeColor() -> UIColor

    // MARK: Settings

    func settingsTitleFont() -> UIFont
    func settingsTitleColor() -> UIColor
    func settingsDonateButtonFont() -> UIFont
    func settingsDonateButtonColor() -> UIColor
    func settingsDonateButtonTextColor() -> UIColor
    func settingsAnalyticsFont() -> UIFont
    func settingsSwitchColor() -> UIColor

    // MARK: About

    func aboutButtonBackgroundColor() -> UIColor
    func aboutButtonTextColor() -> UIColor
    func aboutButtonFont() -> UIFont
    func aboutBodyTextFont() -> UIFont

    // MARK: Welcome

    func welcomeBackgroundColor() -> UIColor
    func welcomeTakeThePowerBackFont() -> UIFont
    func welcomeTextColor() -> UIColor
    func viewPolicyBackgroundColor() -> UIColor
    func agreeToTermsLabelFont() -> UIFont

    // MARK: Actions

    func actionsTitleFont() -> UIFont
    func actionsTitleTextColor() -> UIColor
    func actionsSubTitleFont() -> UIFont
    func actionsSubTitleTextColor() -> UIColor
}
