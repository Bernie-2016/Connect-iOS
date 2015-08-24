import Foundation
import berniesanders

class FakeURLProvider : berniesanders.URLProvider {
    func issuesFeedURL() -> NSURL! {
        fatalError("override me in spec!")
    }
}
