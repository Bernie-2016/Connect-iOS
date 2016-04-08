import UIKit

class DeviceDetective {
    enum DeviceType: Int {
        case Four = 1
        case Five = 2
        case Six = 3
        case SixPlus = 4
        case NewAndShiny = 0
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


func <<T: RawRepresentable where T.RawValue: Comparable>(lhs: T, rhs: T) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

extension DeviceDetective.DeviceType: Comparable {}
