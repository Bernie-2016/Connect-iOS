import UIKit

class ConcreteTabBarItemStylist: TabBarItemStylist {
    private let theme: Theme!

    init(theme: Theme) {
        self.theme = theme
    }

    func applyThemeToBarBarItem(tabBarItem: UITabBarItem, image: UIImage, selectedImage: UIImage) {
        tabBarItem.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)

        let activeTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarActiveTextColor()]
        let inactiveTabBarTextAttributes = [NSFontAttributeName: theme.tabBarFont(), NSForegroundColorAttributeName: theme.tabBarInactiveTextColor()]

        tabBarItem.setTitleTextAttributes(inactiveTabBarTextAttributes, forState: .Normal)
        tabBarItem.setTitleTextAttributes(activeTabBarTextAttributes, forState: .Selected)
    }
}
