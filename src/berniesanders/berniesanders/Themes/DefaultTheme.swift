import UIKit


class DefaultTheme : Theme {
    
    // MARK: Global
    
    func defaultBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func defaultSpinnerColor() -> UIColor {
        return self.silverColor()
    }
    
    // MARK: Tab Bar
    
    func tabBarTintColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func tabBarFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 11)!
    }
    
    func tabBarActiveTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func tabBarInactiveTextColor() -> UIColor {
        return self.silverColor()
    }
    
    // MARK: Navigation Bar
    
    func navigationBarBackgroundColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func navigationBarFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 17)!
    }
    
    func navigationBarTextColor() -> UIColor {
        return UIColor.whiteColor()
    }

    // MARK: News Feed
    
    func newsFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func newsFeedTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    
    func newsFeedDateColor() -> UIColor {
        return self.carnationColor()
    }
    
    func newsFeedDateFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 12)!
    }
    
    // MARK: issues
    
    func issuesFeedTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    
    func issuesFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    // MARK: Feed header
    
    func feedHeaderBackgroundColor() -> UIColor {
        return self.carnationColor()
    }
    
    func feedHeaderTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func feedHeaderFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 10)!
    }
    
    // MARK: News Item detail screen
    
    func newsItemDateFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 12)!
    }
    
    func newsItemDateColor() -> UIColor {
        return self.carnationColor()
    }
    
    func newsItemTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!
    }
    
    func newsItemTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func newsItemBodyFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 13)!
    }
    
    func newsItemBodyColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    func newsFeedHeadlineTitleFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 16)!
    }
    func newsfeedHeadlineTitleColor() -> UIColor {
        return UIColor.whiteColor()
    }
    func newsFeedHeadlineTitleBackgroundColor() -> UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    // MARK: Issue detail screen
    
    func issueTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!
    }
    
    func issueTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func issueBodyFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 13)!
    }
    
    func issueBodyColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    // MARK: Settings
    
    func settingsTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!  
    }
    
    func settingsTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    // MARK: Connect
    
    func connectListFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    
    func connectListColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func connectGoButtonFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!
    }
    
    func connectGoButtonTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func connectGoButtonBackgroundColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func connectZipCodeTextColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    func connectZipCodeBackgroundColor() -> UIColor {
        return self.galleryColor()
    }
    
    func connectZipCodeBorderColor() -> UIColor {
        return self.altoColor()
    }
    
    func connectZipCodeFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    
    func connectZipCodeCornerRadius() -> CGFloat {
        return self.defaultCornerRadius()
    }
    
    func connectZipCodeBorderWidth() -> CGFloat {
        return self.defaultBorderWidth()
    }
    
    func connectZipCodeTextOffset() -> CATransform3D {
        return CATransform3DMakeTranslation(4, 0, 0);
    }
    
    func connectGoButtonCornerRadius() -> CGFloat {
        return self.defaultCornerRadius()
    }
    
    func connectNoResultsTextColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func connectNoResultsFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!
    }
    
    // MARK: Event screen
    
    func eventNameFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 15)!
    }
    
    func eventNameColor() -> UIColor {
        return self.cornflowerBlueColor()
    }


    // MARK: default dimensions
    
    func defaultCornerRadius() -> CGFloat {
        return 2.0
    }
    
    func defaultBorderWidth() -> CGFloat {
        return 1.0
    }
    
    // MARK: color definitions
    
    func cornflowerBlueColor() -> UIColor {
        return UIColor(rgba: "#147FD7")
    }
    
    func carnationColor() -> UIColor {
        return UIColor(rgba: "#fc625c")
    }
    
    func silverColor() -> UIColor {
        return UIColor(rgba: "#c9c9c9")
    }
    
    func galleryColor() -> UIColor {
        return UIColor(rgba: "#eeeeee")
    }
    
    func altoColor() -> UIColor {
        return UIColor(rgba: "#dcdcdc")
    }
}
