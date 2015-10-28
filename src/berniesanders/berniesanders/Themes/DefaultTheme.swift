import UIKit


class DefaultTheme: Theme {
    // swift:disable type_body_length
    // MARK: Global

    func defaultBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultSpinnerColor() -> UIColor { return self.silverColor() }
    func attributionFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func attributionTextColor() -> UIColor { return self.silverColor() }

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor { return self.codGrayColor() }
    func tabBarFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func tabBarActiveTextColor() -> UIColor { return self.galleryColor() }
    func tabBarInactiveTextColor() -> UIColor { return self.silverColor() }

    // MARK: Navigation Bar

    func navigationBarBackgroundColor() -> UIColor { return self.codGrayColor() }
    func navigationBarFont() -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        } else {
            return UIFont.systemFontOfSize(16)
        }
    }
    func navigationBarTextColor() -> UIColor { return UIColor.whiteColor()}

    // MARK: News Feed

    func newsFeedTitleColor() -> UIColor { return self.cornflowerBlueColor() }
    func newsFeedTitleFont() -> UIFont { return UIFont.systemFontOfSize(14) }

    func newsFeedDateColor() -> UIColor { return self.carnationColor() }
    func newsFeedDateFont() -> UIFont { return UIFont.boldSystemFontOfSize(12) }

    // MARK: issues

    func issuesFeedTitleFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func issuesFeedTitleColor() -> UIColor { return self.cornflowerBlueColor() }

    // MARK: Feed header

    func feedHeaderBackgroundColor() -> UIColor { return self.carnationColor() }
    func feedHeaderTextColor() -> UIColor { return UIColor.whiteColor() }
    func feedHeaderFont() -> UIFont { return UIFont.boldSystemFontOfSize(10) }

    // MARK: News Item detail screen

    func newsItemDateFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
    } else {
        return UIFont.systemFontOfSize(12)
    } }
    func newsItemDateColor() -> UIColor { return self.scorpionColor() }
    func newsItemTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 26)! }
    func newsItemTitleColor() -> UIColor { return UIColor.blackColor() }
    func newsItemBodyFont() -> UIFont { return defaultBodyTextFont() }
    func newsItemBodyColor() -> UIColor { return UIColor.blackColor() }
    func newsFeedHeadlineTitleFont() -> UIFont { return UIFont.boldSystemFontOfSize(16) }
    func newsfeedHeadlineTitleColor() -> UIColor { return UIColor.whiteColor() }
    func newsFeedHeadlineTitleBackgroundColor() -> UIColor { return UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) }

    // MARK: Issue detail screen

    func issueTitleFont() -> UIFont { return defaultHeaderFont() }
    func issueTitleColor() -> UIColor { return cornflowerBlueColor() }
    func issueBodyFont() -> UIFont { return defaultBodyTextFont() }
    func issueBodyColor() -> UIColor { return UIColor.blackColor() }
    func defaultButtonBackgroundColor() -> UIColor { return cornflowerBlueColor() }
    func defaultButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func defaultButtonFont() -> UIFont { return UIFont.boldSystemFontOfSize(12) }

    // MARK: Settings

    func settingsTitleFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func settingsTitleColor() -> UIColor { return self.cornflowerBlueColor() }
    func settingsDonateButtonColor() -> UIColor { return self.carnationColor() }
    func settingsDonateButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func settingsDonateButtonFont() -> UIFont { return UIFont.systemFontOfSize(20) }
    func settingsAnalyticsFont() -> UIFont { return defaultBodyTextFont() }

    // MARK: Events

    func eventsListFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func eventsListColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventsInputAccessoryBackgroundColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventsZipCodeTextColor() -> UIColor { return UIColor.blackColor() }
    func eventsZipCodeBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func eventsZipCodeBorderColor() -> UIColor { return self.altoColor() }
    func eventsZipCodeFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func eventsZipCodeCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsZipCodeBorderWidth() -> CGFloat { return self.defaultBorderWidth() }
    func eventsZipCodeTextOffset() -> CATransform3D { return CATransform3DMakeTranslation(4, 0, 0); }
    func eventsGoButtonCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsNoResultsTextColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventsNoResultsFont() -> UIFont { return UIFont.systemFontOfSize(15) }

    // MARK: Event screen

    func eventNameFont() -> UIFont { return self.defaultHeaderFont() }
    func eventNameColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventStartDateFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventStartDateColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventAttendeesFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventAttendeesColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventAddressFont() -> UIFont { return UIFont.systemFontOfSize(13)}
    func eventAddressColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventDescriptionHeadingFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func eventDescriptionHeadingColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventDescriptionColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventDirectionsButtonBackgroundColor() -> UIColor { return self.cornflowerBlueColor() }
    func eventButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func eventDirectionsButtonFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func eventRSVPButtonBackgroundColor() -> UIColor { return self.carnationColor() }
    func eventsInstructionsFont() -> UIFont { return defaultHeaderFont() }
    func eventsInstructionsTextColor() -> UIColor { return silverChaliceColor() }

    // MARK: About screen

    func aboutButtonBackgroundColor() -> UIColor { return cornflowerBlueColor() }
    func aboutButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func aboutButtonFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func aboutBodyTextFont() -> UIFont { return defaultBodyTextFont() }


    // MARK Welcome

    func welcomeLabelFont() -> UIFont { return defaultBodyTextFont() }
    func viewPolicyBackgroundColor() -> UIColor { return silverColor() }
    func agreeToTermsLabelFont() -> UIFont { return UIFont.systemFontOfSize(12) }

    // MARK: default dimensions

    func defaultCornerRadius() -> CGFloat { return 2.0 }
    func defaultBorderWidth() -> CGFloat { return 1.0 }

    // MARK: color definitions

    func cornflowerBlueColor() -> UIColor { return UIColor(rgba: "#147FD7") }
    func carnationColor() -> UIColor { return UIColor(rgba: "#fc625c") }
    func silverColor() -> UIColor { return UIColor(rgba: "#c9c9c9") }
    func codGrayColor() -> UIColor { return UIColor(rgba: "#1b1b1b") }
    func galleryColor() -> UIColor { return UIColor(rgba: "#ececec") }
    func altoColor() -> UIColor { return UIColor(rgba: "#dcdcdc") }
    func silverChaliceColor() -> UIColor { return UIColor(rgba: "#a5a5a5") }
    func chathamsBlueColor() -> UIColor { return UIColor(rgba: "#194d7b") }
    func scorpionColor() -> UIColor { return UIColor(rgba: "#606060") }

    // MARK: font definitions

    func defaultHeaderFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func defaultBodyTextFont() -> UIFont { return  UIFont.systemFontOfSize(14) }
    // swift:enable type_body_length
}
