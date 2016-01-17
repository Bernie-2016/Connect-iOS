import Foundation

class ConcreteDateProvider: DateProvider {
    func now() -> NSDate {
        return NSDate()
    }
}
