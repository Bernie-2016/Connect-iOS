@testable import Connect

class FakeTabBarItemStylist: TabBarItemStylist {
    var lastReceivedTabBarItem: UITabBarItem!
    var lastReceivedTabBarImage: UIImage!
    var lastReceivedTabBarSelectedImage: UIImage!

    func applyThemeToBarBarItem(tabBarItem: UITabBarItem, image: UIImage, selectedImage: UIImage) {
        self.lastReceivedTabBarItem = tabBarItem
        self.lastReceivedTabBarImage = image
        self.lastReceivedTabBarSelectedImage = selectedImage
    }
}
