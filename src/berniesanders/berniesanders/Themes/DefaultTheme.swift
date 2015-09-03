import UIKit


class DefaultTheme : Theme {
    
    // Mark: Tab Bar
    
    func tabBarTintColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func tabBarFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 10)!
    }
    
    func tabBarTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    // MARK: Navigation Bar
    
    func navigationBarBackgroundColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func navigationBarFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 15)!
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
        return UIFont(name: "Lora-Bold", size: 14)!
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
    
    // MARK: Connect
    
    func connectFeedTitleFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    
    func connectFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func connectFeedDateFont() -> UIFont {
        return UIFont(name: "Lora-Bold", size: 12)!
    }
    
    func connectFeedDateColor() -> UIColor {
        return self.carnationColor()
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
        return UIFont(name: "Lora-Bold", size: 12)!
    }
    
    func newsItemBodyColor() -> UIColor {
        return UIColor.blackColor()
    }

    
    // MARK: color definitions
    
    func cornflowerBlueColor() -> UIColor {
        return UIColor(rgba: "#147FD7")
    }
    
    func carnationColor() -> UIColor {
        return UIColor(rgba: "#fc625c")
    }
}
