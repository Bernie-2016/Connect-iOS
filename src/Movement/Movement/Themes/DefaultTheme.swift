import UIKit


class DefaultTheme: Theme {
    // swift:disable type_body_length
    // MARK: Global

    func defaultBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultSpinnerColor() -> UIColor { return self.silverColor() }
    func attributionFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func attributionTextColor() -> UIColor { return self.silverColor() }
    func defaultDisclosureColor() -> UIColor { return self.mineShaftColor() }
    func highlightDisclosureColor() -> UIColor { return self.thunderbirdColor() }

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

    func newsFeedBackgroundColor() -> UIColor { return self.mercuryColor() }
    func newsFeedTitleColor() -> UIColor { return self.tundoraColor() }
    func newsFeedTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 20)! }
    func newsFeedExcerptFont() -> UIFont { return UIFont(name: "Georgia", size: 14)! }
    func newsFeedExcerptColor() -> UIColor {  return self.mineShaftColor() }
    func newsFeedDateFont() -> UIFont { return UIFont.systemFontOfSize(12) }

    // MARK: News Item detail screen

    func newsArticleDateFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func newsArticleDateColor() -> UIColor { return self.scorpionColor() }
    func newsArticleTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 26)! }
    func newsArticleTitleColor() -> UIColor { return UIColor.blackColor() }
    func newsArticleBodyFont() -> UIFont { return UIFont(name: "Georgia", size: 18)! }
    func newsArticleBodyColor() -> UIColor { return UIColor.blackColor() }

    // MARK: issues

    func issuesFeedTitleFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func issuesFeedTitleColor() -> UIColor { return self.tundoraColor() }

    // MARK: Issue detail screen

    func issueTitleFont() -> UIFont { return UIFont.systemFontOfSize(21) }
    func issueTitleColor() -> UIColor { return mineShaftColor() }
    func issueBodyFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func issueBodyColor() -> UIColor { return self.tundoraColor() }

    // MARK: buttons
    func defaultButtonBackgroundColor() -> UIColor { return self.chathamsBlueColor() }
    func defaultButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func defaultButtonFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
    } else {
        return UIFont.systemFontOfSize(17)
        } }


    // MARK: Settings

    func settingsTitleFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func settingsTitleColor() -> UIColor { return tundoraColor() }
    func settingsDonateButtonColor() -> UIColor { return defaultButtonBackgroundColor() }
    func settingsDonateButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func settingsDonateButtonFont() -> UIFont { return UIFont.systemFontOfSize(20) }
    func settingsAnalyticsFont() -> UIFont { return defaultBodyTextFont() }
    func settingsSwitchColor() -> UIColor { return chathamsBlueColor() }

    // MARK: Events

    func eventsListNameFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func eventsListNameColor() -> UIColor { return self.tundoraColor() }
    func eventsListDistanceFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func eventsListDistanceColor() -> UIColor { return self.doveGreyColor() }
    func eventsListDistanceTodayColor() -> UIColor { return self.thunderbirdColor() }
    func eventsListDateFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func eventsListDateColor() -> UIColor { return self.doveGreyColor() }
    func eventsListDateTodayColor() -> UIColor { return self.thunderbirdColor() }
    func eventsListSectionHeaderFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func eventsListSectionHeaderTextColor() -> UIColor { return self.doveGreyColor() }
    func eventsListSectionHeaderBackgroundColor() -> UIColor { return self.seaShellColor() }
    func eventsSearchBarBackgroundColor() -> UIColor { return self.codGrayColor() }
    func eventsZipCodeTextColor() -> UIColor { return self.silverChaliceColor() }
    func eventsZipCodeBackgroundColor() -> UIColor { return self.mineShaftColor() }
    func eventsZipCodeBorderColor() -> UIColor { return self.mineShaftColor() }
    func eventsSearchBarFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
    } else {
        return UIFont.systemFontOfSize(16)
    } }
    func eventsZipCodeCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsZipCodeBorderWidth() -> CGFloat { return self.defaultBorderWidth() }
    func eventsZipCodeTextOffset() -> CATransform3D { return CATransform3DMakeTranslation(4, 0, 0); }
    func eventsGoButtonCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsInformationTextColor() -> UIColor { return self.silverChaliceColor() }
    func eventsNoResultsFont() -> UIFont { return UIFont.systemFontOfSize(21) }
    func eventsCreateEventCTAFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventsInstructionsFont() -> UIFont { return UIFont.systemFontOfSize(21)  }
    func eventsSubInstructionsFont() -> UIFont { return UIFont.systemFontOfSize(13)  }

    // MARK: Event screen

    func eventNameFont() -> UIFont { return UIFont.systemFontOfSize(21) }
    func eventNameColor() -> UIColor { return self.tundoraColor() }
    func eventStartDateFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventStartDateColor() -> UIColor { return self.thunderbirdColor() }
    func eventAddressFont() -> UIFont { return UIFont.systemFontOfSize(13)}
    func eventAddressColor() -> UIColor { return self.emperorColor() }
    func eventDescriptionHeadingFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func eventDescriptionHeadingColor() -> UIColor { return self.tundoraColor() }
    func eventDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventDescriptionColor() -> UIColor { return self.emperorColor() }
    func eventDirectionsButtonBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func eventDirectionsButtonTextColor() -> UIColor { return self.tundoraColor() }
    func eventRSVPButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func eventDirectionsButtonFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func eventRSVPButtonBackgroundColor() -> UIColor { return self.chathamsBlueColor() }
    func eventRSVPButtonFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
    } else {
        return UIFont.systemFontOfSize(17)
    } }
    func eventBackgroundColor() -> UIColor { return self.mercuryColor() }
    func eventTypeFont() -> UIFont { return UIFont.boldSystemFontOfSize(15) }
    func eventTypeColor() -> UIColor { return self.emperorColor() }

    // MARK: About screen

    func aboutButtonBackgroundColor() -> UIColor { return defaultButtonBackgroundColor() }
    func aboutButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func aboutButtonFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func aboutBodyTextFont() -> UIFont { return defaultBodyTextFont() }


    // MARK Welcome

    func welcomeTakeThePowerBackFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(35, weight: UIFontWeightLight)
    } else {
        return UIFont.systemFontOfSize(35)
    } }
    func viewPolicyBackgroundColor() -> UIColor { return silverColor() }
    func agreeToTermsLabelFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func welcomeBackgroundColor() -> UIColor { return codGrayColor() }
    func welcomeTextColor() -> UIColor { return nobelColor() }

    // MARK: default dimensions

    func defaultCornerRadius() -> CGFloat { return 2.0 }
    func defaultBorderWidth() -> CGFloat { return 1.0 }

    // MARK: color definitions

    func silverColor() -> UIColor { return UIColor(rgba: "#c9c9c9") }
    func codGrayColor() -> UIColor { return UIColor(rgba: "#0F0F0F") }
    func galleryColor() -> UIColor { return UIColor(rgba: "#ececec") }
    func mercuryColor() -> UIColor { return UIColor(rgba: "#e8e8e8") }
    func altoColor() -> UIColor { return UIColor(rgba: "#dcdcdc") }
    func silverChaliceColor() -> UIColor { return UIColor(rgba: "#a5a5a5") }
    func chathamsBlueColor() -> UIColor { return UIColor(rgba: "#194d7b") }
    func scorpionColor() -> UIColor { return UIColor(rgba: "#606060") }
    func tundoraColor() -> UIColor { return UIColor(rgba: "#414141") }
    func mineShaftColor() -> UIColor { return UIColor(rgba: "#212121") }
    func thunderbirdColor() -> UIColor { return UIColor(rgba: "#C01E0E") }
    func doveGreyColor() -> UIColor { return UIColor(rgba: "#6d6d6d") }
    func seaShellColor() -> UIColor { return UIColor(rgba: "#f1f1f1") }
    func emperorColor() -> UIColor { return UIColor(rgba: "#555555") }
    func nobelColor() -> UIColor { return UIColor(rgba: "#b5b5b5") }

    // MARK: font definitions

    func defaultHeaderFont() -> UIFont { return UIFont.systemFontOfSize(17) }
    func defaultBodyTextFont() -> UIFont { return  UIFont.systemFontOfSize(14) }
    // swift:enable type_body_length
}
