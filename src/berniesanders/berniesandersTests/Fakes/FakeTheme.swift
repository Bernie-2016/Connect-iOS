import berniesanders
import UIKit

class FakeTheme : berniesanders.Theme {
    func tabBarTintColor() -> UIColor {
        fatalError("override me in the spec!")
    }
    
    func navigationBarBackgroundColor() -> UIColor {
        fatalError("override me in the spec!")
    }
    
    func newsFeedTitleFont() -> UIFont {
        fatalError("override me in the spec!")
    }
    
    func newsFeedTitleColor() -> UIColor {
        fatalError("override me in the spec!")
    }
    
    func newsFeedDateFont() -> UIFont {
        fatalError("override me in the spec!")
    }
    
    func newsFeedDateColor() -> UIColor {
        fatalError("override me in the spec!")
    }
    
    func navigationBarFont() -> UIFont {
        fatalError("override me in the spec!")
    }

    func navigationBarTextColor() -> UIColor {
        fatalError("override me in the spec!")
    }
    
    func tabBarTextColor() -> UIColor {
         fatalError("override me in the spec!")
    }
    
    func tabBarFont() -> UIFont {
         fatalError("override me in the spec!")
    }
    
    func issuesFeedTitleFont() -> UIFont {
         fatalError("override me in the spec!")
    }
    
    func issuesFeedTitleColor() -> UIColor {
         fatalError("override me in the spec!")
    }
}