import UIKit

class VoterRegistrationController: UIViewController {
    let tabBarItemStylist: TabBarItemStylist

    init(tabBarItemStylist: TabBarItemStylist) {
        self.tabBarItemStylist = tabBarItemStylist

        super.init(nibName: nil, bundle: nil)

        tabBarItemStylist.applyThemeToBarBarItem(tabBarItem, image: UIImage(named: "registerTabBarIconInactive")!, selectedImage: UIImage(named: "registerTabBarIcon")!)
        title = NSLocalizedString("Registration_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
