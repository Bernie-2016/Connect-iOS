import UIKit

// swiftlint:disable type_body_length
class DefaultTheme: Theme {
    // MARK: Global

    func defaultCurrentPageIndicatorTintColor() -> UIColor { return UIColor.whiteColor() }
    func defaultPageIndicatorTintColor() -> UIColor { return grayChateauColor }
    func defaultBackgroundColor() -> UIColor { return seaShellColor }
    func contentBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultSpinnerColor() -> UIColor { return silverColor }
    func defaultDisclosureColor() -> UIColor { return doveGreyColor }
    func highlightDisclosureColor() -> UIColor { return thunderbirdColor }
    func defaultTableSectionHeaderFont() -> UIFont { return tableSectionHeaderFont() }
    func defaultTableSectionHeaderTextColor() -> UIColor { return tableSectionHeaderTextColor() }
    func defaultTableSectionHeaderBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func defaultTableSeparatorColor() -> UIColor { return galleryColor }
    func defaultBodyTextFont() -> UIFont { return UIFont(name: "Georgia", size: 17)!  }
    func defaultBodyTextColor() -> UIColor { return UIColor.blackColor() }
    func defaultTableCellBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func defaultButtonBorderColor() -> UIColor { return coalMinerColor }
    func defaultBodyTextLineHeight() -> CGFloat { return 24.0 }
    func fullWidthRSVPButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func fullWidthButtonBackgroundColor() -> UIColor { return scienceBlueColor }
    func fullWidthRSVPButtonFont() -> UIFont { return h3HeaderFont() }

    // MARK: Tab Bar

    func tabBarTintColor() -> UIColor { return UIColor.whiteColor()     }
    func tabBarFont() -> UIFont { return UIFont.systemFontOfSize(11) }
    func tabBarActiveTextColor() -> UIColor { return scienceBlueColor }
    func tabBarInactiveTextColor() -> UIColor { return grayChateauColor }

    // MARK: Navigation Bar
    func navigationBarTintColor() -> UIColor { return scienceBlueColor }
    func navigationBarBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func navigationBarFont() -> UIFont { return UIFont.boldSystemFontOfSize(16) }
    func navigationBarButtonFont() -> UIFont { return UIFont.systemFontOfSize(16) }
    func navigationBarTextColor() -> UIColor { return coalMinerColor }
    func navigationBarButtonTextColor() -> UIColor { return scienceBlueColor }

    // MARK: News Feed
    func newsFeedBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func newsFeedTitleColor() -> UIColor { return h2HeaderTextColor() }
    func newsFeedTitleFont() -> UIFont { return h2HeaderFont() }
    func newsFeedExcerptFont() -> UIFont { return subHeadingFont() }
    func newsFeedExcerptColor() -> UIColor {  return subHeadingTextColor() }
    func newsFeedDateFont() -> UIFont { return tinyTextFont() }
    func newsFeedDateColor() -> UIColor { return subHeadingTextColor() }
    func newsFeedVideoOverlayBackgroundColor() -> UIColor { return UIColor(red: 0, green: 0, blue: 0, alpha: 0.7) }
    func newsFeedCellBorderColor() -> UIColor { return altoColor }
    func newsFeedInfoButtonTintColor() -> UIColor { return boulderColor }

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

    // MARK: buttons
    func defaultButtonBackgroundColor() -> UIColor { return scienceBlueColor }
    func defaultButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func defaultButtonDisabledTextColor() -> UIColor { return grayChateauColor }
    func defaultButtonFont() -> UIFont { return h2HeaderFont() }

    // MARK: Settings

    func settingsTitleFont() -> UIFont { return h3HeaderFont() }
    func settingsTitleColor() -> UIColor { return h3HeaderTextColor() }
    func settingsAnalyticsFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func settingsSwitchColor() -> UIColor { return scienceBlueColor }

    // MARK: Events

    func eventsListNameFont() -> UIFont { return h3HeaderFont() }
    func eventsListNameColor() -> UIColor { return h3HeaderTextColor()}
    func eventsListDateFont() -> UIFont { return tinyTextFont() }
    func eventsListDateColor() -> UIColor { return tinyTextColor() }
    func eventsSearchBarBackgroundColor() -> UIColor { return navigationBarBackgroundColor() }
    func eventsAddressTextColor() -> UIColor { return coalMinerColor }
    func eventsAddressPlaceholderTextColor() -> UIColor { return coalMinerColor }
    func eventsAddressBackgroundColor() -> UIColor { return defaultBackgroundColor() }
    func eventsAddressBorderColor() -> UIColor { return defaultBackgroundColor() }
    func eventsSearchBarFont() -> UIFont { return UIFont.systemFontOfSize(15) }
    func eventsAddressCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsAddressBorderWidth() -> CGFloat { return self.defaultBorderWidth() }
    func eventsAddressTextOffset() -> CATransform3D { return CATransform3DMakeTranslation(14, 0, 0); }
    func eventsGoButtonCornerRadius() -> CGFloat { return self.defaultCornerRadius() }
    func eventsInformationTextColor() -> UIColor { return defaultBodyTextColor() }
    func eventsNoResultsFont() -> UIFont { return UIFont.systemFontOfSize(21) }
    func eventsCreateEventCTAFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventsInstructionsFont() -> UIFont { return UIFont.systemFontOfSize(21)  }
    func eventsSubInstructionsFont() -> UIFont { return UIFont.systemFontOfSize(13)  }

    func eventsFilterLabelFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventsFilterLabelTextColor() -> UIColor { return grayChateauColor }
    func eventsFilterButtonTextColor() -> UIColor { return scienceBlueColor }
    func eventSearchBarSearchBarTopPadding() -> CGFloat { return  9 }
    func eventSearchBarVerticalShift() -> CGFloat { return 8 }
    func eventSearchBarHorizontalPadding() -> CGFloat { return 15 }
    func eventSearchBarSearchBarHeight() -> CGFloat { return 30 }
    func eventSearchBarFilterLabelBottomPadding() -> CGFloat { return 7 }
    func eventsErrorTextColor() -> UIColor { return silverChaliceColor }
    func eventsErrorHeadingFont() -> UIFont { return UIFont.systemFontOfSize(21) }
    func eventsErrorDetailFont() -> UIFont { return UIFont.systemFontOfSize(13) }

    // MARK: Event screen

    func eventNameFont() -> UIFont { return defaultHeaderFont() }
    func eventNameColor() -> UIColor { return h1HeaderTextColor() }
    func eventStartDateFont() -> UIFont { return subHeadingFont() }
    func eventStartDateColor() -> UIColor { return cinnabarColor }
    func eventAddressFont() -> UIFont { return subHeadingFont() }
    func eventAddressColor() -> UIColor { return subHeadingTextColor() }
    func eventDescriptionHeadingFont() -> UIFont { return h3HeaderFont() }
    func eventDescriptionHeadingColor() -> UIColor { return h3HeaderTextColor() }
    func eventDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(13) }
    func eventDescriptionColor() -> UIColor { return h3HeaderTextColor() }
    func eventDirectionsButtonBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func eventDirectionsButtonTextColor() -> UIColor { return h3HeaderTextColor() }
    func eventDirectionsButtonFont() -> UIFont { return h3HeaderFont() }
    func eventBackgroundColor() -> UIColor { return defaultBackgroundColor() }

    // MARK: About screen

    func aboutButtonBackgroundColor() -> UIColor { return defaultButtonBackgroundColor() }
    func aboutButtonTextColor() -> UIColor { return UIColor.whiteColor() }
    func aboutButtonFont() -> UIFont { return h3HeaderFont() }
    func aboutBodyTextFont() -> UIFont { return defaultBodyTextFont() }

    // MARK Welcome

    func welcomeTakeThePowerBackFont() -> UIFont {
        var fontSize: CGFloat!

        let deviceType = DeviceDetective.identifyDevice()
        switch deviceType {
        case .Four, .Five, .NewAndShiny:
            fontSize = 22
        default:
            fontSize = 26
        }

        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(fontSize, weight: UIFontWeightLight)
        } else {
            return UIFont.systemFontOfSize(fontSize)
        }
    }
    func welcomeBackgroundColor() -> UIColor { return UIColor.whiteColor() }
    func welcomeTextColor() -> UIColor { return tundoraColor }

    // MARK: Actions

    func actionsBackgroundColor() -> UIColor { return mackerelGrayColor }
    func actionsTitleFont() -> UIFont { return semiBoldSystemFontOfSize(18) }
    func actionsTitleTextColor() -> UIColor { return wildSandColor }
    func actionsShortDescriptionFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func actionsShortDescriptionTextColor() -> UIColor { return cadetBlueColor }
    func actionsShortLoadingMessageFont() -> UIFont { return lightSystemFontOfSize(13) }
    func actionsShortLoadingMessageTextColor() -> UIColor { return UIColor.whiteColor() }
    func actionsErrorMessageFont() -> UIFont { return lightSystemFontOfSize(13) }
    func actionsErrorMessageTextColor() -> UIColor { return UIColor.whiteColor() }
    func actionsInfoButtonTintColor() -> UIColor { return UIColor.whiteColor() }
    // MARK: Markdown

    func markdownH1Font() -> UIFont { return h1HeaderFont() }
    func markdownH2Font() -> UIFont { return h2HeaderFont() }
    func markdownH3Font() -> UIFont { return h3HeaderFont() }
    func markdownH4Font() -> UIFont { return h4HeaderFont() }
    func markdownH5Font() -> UIFont { return h5HeaderFont() }
    func markdownH6Font() -> UIFont { return h6HeaderFont() }
    func markdownBodyFont() -> UIFont { return defaultBodyTextFont() }
    func markdownBodyTextColor() -> UIColor { return defaultBodyTextColor() }
    func markdownBodyLinkTextColor() -> UIColor { return scienceBlueColor }

    // MARK: default dimensions

    func defaultCornerRadius() -> CGFloat { return 5.0 }
    func defaultBorderWidth() -> CGFloat { return 1.0 }

    // new colors
    let codGrayColor = UIColor(rgba: "#0F0F0F")
    let mackerelGrayColor = UIColor(rgba: "#141414")
    let nobelColor = UIColor(rgba: "#b5b5b5")
    let silverColor = UIColor(rgba: "#c9c9c9")
    let thunderbirdColor = UIColor(rgba: "#C01E0E")
    let coalMinerColor = UIColor(rgba: "#333333")
    let boulderColor = UIColor(rgba: "#7a7a7a")
    let arachnidColor = UIColor(rgba: "#5a5a5a")
    let grayChateauColor = UIColor(rgba: "#969EA6")
    let seaShellColor = UIColor(rgba: "#f1f1f1")
    let doveGreyColor = UIColor(rgba: "#6d6d6d")
    let galleryColor = UIColor(rgba: "#efefef")
    let scienceBlueColor = UIColor(rgba: "#0176D7")
    let altoColor = UIColor(rgba: "#e0e0e0")
    let silverChaliceColor = UIColor(rgba: "#a5a5a5")
    let tundoraColor = UIColor(rgba: "#4b4b4b")
    let wildSandColor = UIColor(rgba: "#F4F4F4")
    let cadetBlueColor = UIColor(rgba: "#A5B5C3")
    let cinnabarColor = UIColor(rgba: "#ec3e3f")

    // MARK: font definitions

    func defaultHeaderFont() -> UIFont { return UIFont.systemFontOfSize(17) }

    // new fonts
    func h1HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(21) }
    func h1HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h2HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(16) }
    func h2HeaderTextColor() -> UIColor { return UIColor.blackColor() }

    func h3HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(15) }
    func h3HeaderTextColor() -> UIColor { return coalMinerColor }

    func h4HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(14) }
    func h5HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(13) }
    func h6HeaderFont() -> UIFont { return semiBoldSystemFontOfSize(12) }

    func subHeadingFont() -> UIFont { return UIFont.systemFontOfSize(14) }
    func subHeadingTextColor() -> UIColor { return boulderColor }

    func tinyTextFont() -> UIFont { return UIFont.systemFontOfSize(12) }
    func tinyTextColor() -> UIColor { return arachnidColor }

    func tableSectionHeaderFont() -> UIFont { return semiBoldSystemFontOfSize(13) }
    func tableSectionHeaderTextColor() -> UIColor { return boulderColor }

    func mediumSystemFontOfSize(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: ".SFUIDisplay-Medium", size: size) else {
            return UIFont.systemFontOfSize(size)
        }

        return font
    }

    func semiBoldSystemFontOfSize(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: UIFontWeightSemibold)
        } else {
            return UIFont.systemFontOfSize(size)
        }
    }

    func lightSystemFontOfSize(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: UIFontWeightLight)
        } else {
            return UIFont.systemFontOfSize(size)
        }
    }
}
// swift:enable type_body_length
