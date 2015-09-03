import Foundation
import berniesanders

class FakeURLProvider : berniesanders.URLProvider {
    func issuesFeedURL() -> NSURL! {
        fatalError("override me in spec!")
    }
    
    func newsFeedURL() -> NSURL! {
        fatalError("override me in spec!")
    }
    
    func bernieCrowdURL() -> NSURL! {
        fatalError("override me in spec!")
    }
}
