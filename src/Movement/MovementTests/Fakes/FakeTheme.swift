import UIKit

@testable import Movement

class FakeTheme: Theme {
    func tabBarTintColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func navigationBarBackgroundColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsFeedBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedTitleFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedTitleColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedExcerptFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedExcerptColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedDateFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func newsFeedVideoOverlayBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func highlightDisclosureColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultDisclosureColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultTableSectionHeaderFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultTableSectionHeaderTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultTableSectionHeaderBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultTableSeparatorColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }

    func navigationBarFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func navigationBarTextColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func tabBarActiveTextColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func tabBarInactiveTextColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func tabBarFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issuesFeedTitleFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issuesFeedTitleColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func feedHeaderBackgroundColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func feedHeaderTextColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func feedHeaderFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleDateFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleDateColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleTitleFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleTitleColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleBodyFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func newsArticleBodyColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func defaultBackgroundColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issueTitleColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issueTitleFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issueBodyFont() -> UIFont {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func issueBodyColor() -> UIColor {
        fatalError("FakeTheme used without being overridden in spec!")
    }

    func settingsTitleFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func settingsTitleColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func settingsSwitchColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }

    func eventsListNameFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsListNameColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsListDateFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsListDateColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsSearchBarBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodePlaceholderTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeBorderColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsSearchBarFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeCornerRadius() -> CGFloat { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeBorderWidth() -> CGFloat { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsZipCodeTextOffset() -> CATransform3D { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsGoButtonCornerRadius() -> CGFloat { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsInformationTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsNoResultsFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsCreateEventCTAFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultSpinnerColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventNameFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventNameColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventStartDateFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventStartDateColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventAttendeesFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventAttendeesColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventAddressFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventAddressColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDescriptionHeadingFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDescriptionHeadingColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDescriptionFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDescriptionColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDirectionsButtonBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDirectionsButtonTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventDirectionsButtonFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventRSVPButtonTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventRSVPButtonFont() -> UIFont  { fatalError("FakeTheme used without being overridden in spec!") }
    func eventRSVPButtonBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventTypeFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventTypeColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsInstructionsFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func eventsSubInstructionsFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func aboutButtonBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func aboutButtonTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func aboutButtonFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func aboutBodyTextFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func attributionFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func attributionTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultButtonBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultButtonTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultButtonFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func welcomeTakeThePowerBackFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func viewPolicyBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func agreeToTermsLabelFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func settingsAnalyticsFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func welcomeBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func welcomeTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func videoDateFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func videoDateColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func videoTitleFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func videoTitleColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func videoDescriptionFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func videoDescriptionColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func actionsTitleFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func actionsTitleTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func actionsSubTitleFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
    func actionsSubTitleTextColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func contentBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func defaultTableCellBackgroundColor() -> UIColor { fatalError("FakeTheme used without being overridden in spec!") }
    func navigationBarButtonFont() -> UIFont { fatalError("FakeTheme used without being overridden in spec!") }
}
