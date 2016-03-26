import UIKit

class DeviceDetective {
    enum DeviceType {
        case Four
        case Five
        case Six
        case SixPlus
        case NewAndShiny
    }

    class func identifyDevice() -> DeviceType {
        let screen = UIScreen.mainScreen()

        switch screen.bounds.height {
        case 480:
            return .Four
        case 568:
            return .Five
        case 667:
            return .Six
        case 736:
            return .SixPlus
        default:
            return .NewAndShiny
        }
    }
}
