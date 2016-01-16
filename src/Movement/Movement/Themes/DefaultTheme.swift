import UIKit

// swiftlint:disable type_body_length


class DefaultTheme: Theme {
    // MARK: Global
    func defaultBackgroundColor() -> UIColor { return seaShellColor }
    func contentBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultSpinnerColor() -> UIColor { return self.silverColor() }
    func attributionFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func attributionTextColor() -> UIColor { return self.silverColor() }
    func defaultDisclosureColor() -> UIColor { return doveGreyColor }
    func highlightDisclosureColor() -> UIColor { return self.thunderbirdColor() }
    func defaultTableSectionHeaderFont() -> UIFont { return tableSectionHeaderFont() }
    func defaultTableSectionHeaderTextColor() -> UIColor { return tableSectionHeaderTextColor() }
    func defaultTableSectionHeaderBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func defaultTableSeparatorColor() -> UIColor { return galleryColor }
    func defaultBodyTextFont() -> UIFont { return UIFont(name: "Georgia", size: 17)!  }
    func defaultBodyTextColor() -> UIColor { return coalMinerColor }

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor { return self.codGrayColor() }
    func tabBarFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func tabBarActiveTextColor() -> UIColor { return calypsoColor }
    func tabBarInactiveTextColor() -> UIColor { return grayChateauColor }

    // MARK: Navigation Bar
    func navigationBarBackgroundColor() -> UIColor { return chathamsBlueColor }
    func navigationBarFont() -> UIFont { return UIFont.systemFontOfSize(18) }
    func navigationBarTextColor() -> UIColor { return UIColor.whiteColor()}

    // MARK: News Feed
    func newsFeedBackgroundColor() -> UIColor { return self.mercuryColor() }
    func newsFeedTitleColor() -> UIColor { return self.tundoraColor() }
    func newsFeedTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 20)! }
    func newsFeedExcerptFont() -> UIFont { return UIFont(name: "Georgia", size: 14)! }
    func newsFeedExcerptColor() -> UIColor {  return self.mineShaftColor() }
    func newsFeedDateFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func newsFeedVideoOverlayBackgroundColor() -> UIColor { return UIColor(red: 0, green: 0, blue: 0, alpha: 0.7) }

    // MARK: News Article screen

    func newsArticleDateFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func newsArticleDateColor() -> UIColor { return self.scorpionColor() }
    func newsArticleTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 26)! }
    func newsArticleTitleColor() -> UIColor { return UIColor.blackColor() }
    func newsArticleBodyFont() -> UIFont { return UIFont(name: "Georgia", size: 18)! }
    func newsArticleBodyColor() -> UIColor { return UIColor.blackColor() }

    // MARK: Video Screen

    func videoDateFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func videoDateColor() -> UIColor { return self.scorpionColor() }
    func videoTitleFont() -> UIFont { return UIFont(name: "Georgia-Bold", size: 26)! }
    func videoTitleColor() -> UIColor { return UIColor.blackColor() }
    func videoDescriptionFont() -> UIFont { return UIFont(name: "Georgia", size: 18)! }
    func videoDescriptionColor() -> UIColor { return UIColor.blackColor() }

    // MARK: issues

    func issuesFeedTitleFont() -> UIFont { return h3HeaderFont() }
    func issuesFeedTitleColor() -> UIColor { return h3HeaderTextColor() }

    // MARK: Issue detail screen

    func issueTitleFont() -> UIFont { return h1HeaderFont() }
    func issueTitleColor() -> UIColor { return h1HeaderTextColor() }
    func issueBodyFont() -> UIFont { return defaultBodyTextFont() }
    func issueBodyColor() -> UIColor { return defaultBodyTextColor() }

    // MARK: buttons
    func defaultButtonBackgroundColor() -> UIColor { return chathamsBlueColor }
    func defaultButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func defaultButtonFont() -> UIFont { return h2HeaderFont() }

    // MARK: Settings

    func settingsTitleFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func settingsTitleColor() -> UIColor { return tundoraColor() }
    func settingsDonateButtonColor() -> UIColor { return defaultButtonBackgroundColor() }
    func settingsDonateButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func settingsDonateButtonFont() -> UIFont { return UIFont.systemFontOfSize(20) }
    func settingsAnalyticsFont() -> UIFont { return defaultBodyTextFont() }
    func settingsSwitchColor() -> UIColor { return chathamsBlueColor }

    // MARK: Events

    func eventsListNameFont() -> UIFont { return h3HeaderFont() }
    func eventsListNameColor() -> UIColor { return h3HeaderTextColor()}
    func eventsListDateFont() -> UIFont { return tinyTextFont() }
    func eventsListDateColor() -> UIColor { return tinyTextColor() }
    func eventsSearchBarBackgroundColor() -> UIColor { return navigationBarBackgroundColor() }
    func eventsZipCodeTextColor() -> UIColor { return UIColor.whiteColor() }
    func eventsZipCodePlaceholderTextColor() -> UIColor { return grayChateauColor }
    func eventsZipCodeBackgroundColor() -> UIColor { return biscayColor }
    func eventsZipCodeBorderColor() -> UIColor { return biscayColor }
    func eventsSearchBarFont() -> UIFont { return h3HeaderFont() }
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

    func eventNameFont() -> UIFont { return h1HeaderFont() }
    func eventNameColor() -> UIColor { return h1HeaderTextColor() }
    func eventStartDateFont() -> UIFont { return subHeadingFont() }
    func eventStartDateColor() -> UIColor { return subHeadingTextColor() }
    func eventAddressFont() -> UIFont { return subHeadingFont() }
    func eventAddressColor() -> UIColor { return subHeadingTextColor() }
    func eventDescriptionHeadingFont() -> UIFont { return h3HeaderFont() }
    func eventDescriptionHeadingColor() -> UIColor { return h3HeaderTextColor() }
    func eventDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventDescriptionColor() -> UIColor { return self.emperorColor() }
    func eventDirectionsButtonBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func eventDirectionsButtonTextColor() -> UIColor { return h3HeaderTextColor() }
    func eventDirectionsButtonFont() -> UIFont { return h3HeaderFont() }
    func eventRSVPButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func eventRSVPButtonBackgroundColor() -> UIColor { return navigationBarBackgroundColor() }
    func eventRSVPButtonFont() -> UIFont { return h3HeaderFont() }
    func eventBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func eventTypeFont() -> UIFont { return subHeadingFont() }
    func eventTypeColor() -> UIColor { return subHeadingTextColor() }

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

    // MARK: Actions

    func actionsTitleFont() -> UIFont { return UIFont.boldSystemFontOfSize(14) }
    func actionsTitleTextColor() -> UIColor { return self.tundoraColor() }
    func actionsSubTitleFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func actionsSubTitleTextColor() -> UIColor { return self.doveGreyColor }

    // MARK: default dimensions

    func defaultCornerRadius() -> CGFloat { return 2.0 }
    func defaultBorderWidth() -> CGFloat { return 1.0 }

    // MARK: color definitions

    func silverColor() -> UIColor { return UIColor(rgba: "#c9c9c9") }
    func codGrayColor() -> UIColor { return UIColor(rgba: "#0F0F0F") }
    func mercuryColor() -> UIColor { return UIColor(rgba: "#e8e8e8") }
    func altoColor() -> UIColor { return UIColor(rgba: "#dcdcdc") }
    func silverChaliceColor() -> UIColor { return UIColor(rgba: "#a5a5a5") }
    func scorpionColor() -> UIColor { return UIColor(rgba: "#606060") }
    func tundoraColor() -> UIColor { return UIColor(rgba: "#414141") }
    func mineShaftColor() -> UIColor { return UIColor(rgba: "#212121") }
    func thunderbirdColor() -> UIColor { return UIColor(rgba: "#C01E0E") }
    func emperorColor() -> UIColor { return UIColor(rgba: "#555555") }
    func nobelColor() -> UIColor { return UIColor(rgba: "#b5b5b5") }


    // new colors
    let coalMinerColor = UIColor(rgba: "#333333")
    let boulderColor = UIColor(rgba: "#7a7a7a")
    let arachnidColor = UIColor(rgba: "#5a5a5a")
    let grayChateauColor = UIColor(rgba: "#969EA6")
    let calypsoColor = UIColor(rgba: "#396899")
    let seaShellColor = UIColor(rgba: "#f1f1f1")
    let doveGreyColor = UIColor(rgba: "#6d6d6d")
    let chathamsBlueColor = UIColor(rgba: "#194d7b")
    let biscayColor = UIColor(rgba: "#163d5f")
    let galleryColor = UIColor(rgba: "#efefef")

    // MARK: font definitions

    func defaultHeaderFont() -> UIFont { return UIFont.systemFontOfSize(17) }

    // new fonts
    func h1HeaderFont() -> UIFont { return sanfranciscoMediumFontOfSize(25) }
    func h1HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h2HeaderFont() -> UIFont { return sanfranciscoMediumFontOfSize(18) }
    func h2HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h3HeaderFont() -> UIFont { return sanfranciscoMediumFontOfSize(15) }
    func h3HeaderTextColor() -> UIColor { return coalMinerColor }

    func subHeadingFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func subHeadingTextColor() -> UIColor { return boulderColor }

    func tinyTextFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func tinyTextColor() -> UIColor { return arachnidColor }

    func tableSectionHeaderFont() -> UIFont { return sanfranciscoMediumFontOfSize(13) }
    func tableSectionHeaderTextColor() -> UIColor { return boulderColor }


    func sanfranciscoMediumFontOfSize(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: UIFontWeightMedium)
        } else {
            return UIFont.systemFontOfSize(size)
        }
    }
}
// swift:enable type_body_length
