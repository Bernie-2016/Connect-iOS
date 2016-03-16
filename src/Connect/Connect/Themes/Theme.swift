import UIKit


protocol Theme {
    // MARK: Global

    func defaultBackgroundColor() -> UIColor
    func contentBackgroundColor() -> UIColor
    func defaultSpinnerColor() -> UIColor
    func attributionFont() -> UIFont
    func attributionTextColor() -> UIColor
    func attributionButtonBackgroundColor() -> UIColor
    func defaultButtonBackgroundColor() -> UIColor
    func defaultButtonTextColor() -> UIColor
    func defaultButtonDisabledTextColor() -> UIColor
    func defaultButtonFont() -> UIFont
    func defaultButtonBorderColor() -> UIColor
    func defaultDisclosureColor() -> UIColor
    func highlightDisclosureColor() -> UIColor
    func defaultTableSectionHeaderFont() -> UIFont
    func defaultTableSectionHeaderTextColor() -> UIColor
    func defaultTableSectionHeaderBackgroundColor() -> UIColor
    func defaultTableSeparatorColor() -> UIColor
    func defaultTableCellBackgroundColor() -> UIColor
    func defaultBodyTextLineHeight() -> CGFloat

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor
    func tabBarActiveTextColor() -> UIColor
    func tabBarInactiveTextColor() -> UIColor
    func tabBarFont() -> UIFont

    // MARK: Navigation Bar

    func navigationBarBackgroundColor() -> UIColor
    func navigationBarTintColor() -> UIColor
    func navigationBarFont() -> UIFont
    func navigationBarTextColor() -> UIColor
    func navigationBarButtonFont() -> UIFont
    func navigationBarButtonTextColor() -> UIColor

    // MARK: News Feed

    func newsFeedBackgroundColor() -> UIColor
    func newsFeedTitleFont() -> UIFont
    func newsFeedTitleColor() -> UIColor
    func newsFeedExcerptFont() -> UIFont
    func newsFeedExcerptColor() -> UIColor
    func newsFeedDateFont() -> UIFont
    func newsFeedDateColor() -> UIColor
    func newsFeedVideoOverlayBackgroundColor() -> UIColor
    func newsFeedCellBorderColor() -> UIColor

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

    // MARK: Events screen

    func eventsListNameFont() -> UIFont
    func eventsListNameColor() -> UIColor
    func eventsListDateFont() -> UIFont
    func eventsListDateColor() -> UIColor
    func eventsSearchBarBackgroundColor() -> UIColor
    func eventsZipCodeTextColor() -> UIColor
    func eventsZipCodePlaceholderTextColor() -> UIColor
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
    func eventsFilterLabelFont() -> UIFont
    func eventsFilterLabelTextColor() -> UIColor
    func eventsFilterButtonTextColor() -> UIColor

    func eventSearchBarSearchBarTopPadding() -> CGFloat
    func eventSearchBarVerticalShift() -> CGFloat
    func eventSearchBarHorizontalPadding() -> CGFloat
    func eventSearchBarSearchBarHeight() -> CGFloat
    func eventSearchBarFilterLabelBottomPadding() -> CGFloat

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

    // MARK: Action Alerts

    func actionAlertDateFont() -> UIFont
    func actionAlertDateTextColor() -> UIColor
    func actionAlertTitleFont() -> UIFont
    func actionAlertTitleTextColor() -> UIColor
    func actionAlertH1Font() -> UIFont
    func actionAlertH2Font() -> UIFont
    func actionAlertH3Font() -> UIFont
    func actionAlertH4Font() -> UIFont
    func actionAlertH5Font() -> UIFont
    func actionAlertH6Font() -> UIFont
    func actionAlertBodyFont() -> UIFont
    func actionAlertBodyTextColor() -> UIColor
    func actionAlertBodyLinkTextColor() -> UIColor
    func actionAlertShareButtonFont() -> UIFont
    func actionAlertShareButtonTextColor() -> UIColor
    func actionAlertShareButtonBorderColor() -> UIColor
    func actionAlertShareButtonBackgroundColor() -> UIColor
}
