import UIKit

// swiftlint:disable type_body_length

class DefaultTheme: Theme {
    // MARK: Global
    func defaultBackgroundColor() -> UIColor { return seaShellColor }
    func contentBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultSpinnerColor() -> UIColor { return silverColor }
    func attributionFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func attributionTextColor() -> UIColor { return silverColor }
    func defaultDisclosureColor() -> UIColor { return doveGreyColor }
    func highlightDisclosureColor() -> UIColor { return thunderbirdColor }
    func defaultTableSectionHeaderFont() -> UIFont { return tableSectionHeaderFont() }
    func defaultTableSectionHeaderTextColor() -> UIColor { return tableSectionHeaderTextColor() }
    func defaultTableSectionHeaderBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func defaultTableSeparatorColor() -> UIColor { return galleryColor }
    func defaultBodyTextFont() -> UIFont { return UIFont(name: "Georgia", size: 17)!  }
    func defaultBodyTextColor() -> UIColor { return UIColor.blackColor() }
    func defaultTableCellBackgroundColor() -> UIColor { return UIColor.whiteColor() }

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor { return UIColor.whiteColor()     }
    func tabBarFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func tabBarActiveTextColor() -> UIColor { return calypsoColor }
    func tabBarInactiveTextColor() -> UIColor { return grayChateauColor }

    // MARK: Navigation Bar
    func navigationBarBackgroundColor() -> UIColor { return chathamsBlueColor }
    func navigationBarFont() -> UIFont { return UIFont.systemFontOfSize(18) }
    func navigationBarButtonFont() -> UIFont { return UIFont.systemFontOfSize(16) }
    func navigationBarTextColor() -> UIColor { return UIColor.whiteColor()}

    // MARK: News Feed
    func newsFeedBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func newsFeedTitleColor() -> UIColor { return h2HeaderTextColor() }
    func newsFeedTitleFont() -> UIFont { return h2HeaderFont() }
    func newsFeedExcerptFont() -> UIFont { return subHeadingFont() }
    func newsFeedExcerptColor() -> UIColor {  return subHeadingTextColor() }
    func newsFeedDateFont() -> UIFont { return tinyTextFont() }
    func newsFeedVideoOverlayBackgroundColor() -> UIColor { return UIColor(red: 0, green: 0, blue: 0, alpha: 0.7) }

    // MARK: News Article screen

    func newsArticleDateFont() -> UIFont { return tinyTextFont() }
    func newsArticleDateColor() -> UIColor { return tinyTextColor() }
    func newsArticleTitleFont() -> UIFont { return h1HeaderFont() }
    func newsArticleTitleColor() -> UIColor { return h1HeaderTextColor() }
    func newsArticleBodyFont() -> UIFont { return defaultBodyTextFont() }
    func newsArticleBodyColor() -> UIColor { return defaultBodyTextColor() }

    // MARK: Video Screen

    func videoDateFont() -> UIFont { return tinyTextFont() }
    func videoDateColor() -> UIColor { return tinyTextColor() }
    func videoTitleFont() -> UIFont { return h1HeaderFont() }
    func videoTitleColor() -> UIColor { return h1HeaderTextColor() }
    func videoDescriptionFont() -> UIFont { return defaultBodyTextFont() }
    func videoDescriptionColor() -> UIColor { return defaultBodyTextColor() }

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

    func settingsTitleFont() -> UIFont { return h3HeaderFont() }
    func settingsTitleColor() -> UIColor { return h3HeaderTextColor() }
    func settingsAnalyticsFont() -> UIFont { return UIFont.systemFontOfSize(13) }
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
    func eventsZipCodeTextOffset() -> CATransform3D { return CATransform3DMakeTranslation(14, 0, 0); }
    func eventsGoButtonCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsInformationTextColor() -> UIColor { return defaultBodyTextColor() }
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
    func eventDescriptionColor() -> UIColor { return h3HeaderTextColor() }
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
    func aboutButtonFont() -> UIFont { return h3HeaderFont() }
    func aboutBodyTextFont() -> UIFont { return defaultBodyTextFont() }


    // MARK Welcome

    func welcomeTakeThePowerBackFont() -> UIFont { if #available(iOS 8.2, *) {
        return UIFont.systemFontOfSize(35, weight: UIFontWeightLight)
    } else {
        return UIFont.systemFontOfSize(35)
    } }
    func viewPolicyBackgroundColor() -> UIColor { return silverColor }
    func agreeToTermsLabelFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func welcomeBackgroundColor() -> UIColor { return codGrayColor }
    func welcomeTextColor() -> UIColor { return nobelColor }

    // MARK: Actions

    func actionsTitleFont() -> UIFont { return h3HeaderFont() }
    func actionsTitleTextColor() -> UIColor { return h3HeaderTextColor() }
    func actionsSubTitleFont() -> UIFont { return subHeadingFont() }
    func actionsSubTitleTextColor() -> UIColor { return subHeadingTextColor() }

    // MARK: default dimensions

    func defaultCornerRadius() -> CGFloat { return 5.0 }
    func defaultBorderWidth() -> CGFloat { return 1.0 }


    // new colors
    let codGrayColor = UIColor(rgba: "#0F0F0F")
    let nobelColor = UIColor(rgba: "#b5b5b5")
    let silverColor = UIColor(rgba: "#c9c9c9")
    let thunderbirdColor = UIColor(rgba: "#C01E0E")
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
    func h1HeaderFont() -> UIFont { return mediumSystemFontOfSize(21) }
    func h1HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h2HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(16) }
    func h2HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h3HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(15) }
    func h3HeaderTextColor() -> UIColor { return coalMinerColor }

    func subHeadingFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func subHeadingTextColor() -> UIColor { return boulderColor }

    func tinyTextFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func tinyTextColor() -> UIColor { return arachnidColor }

    func tableSectionHeaderFont() -> UIFont { return mediumSystemFontOfSize(13) }
    func tableSectionHeaderTextColor() -> UIColor { return boulderColor }

    func mediumSystemFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: ".SFUIDisplay-Medium", size: size)!
    }

    func semiBoldSystemFontOfSize(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: UIFontWeightSemibold)
        } else {
            return UIFont.systemFontOfSize(size)
        }
    }

}
// swift:enable type_body_length
