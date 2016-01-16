import Foundation
import CoreLocation

@testable import Movement

class FakeURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func newsFeedURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func bernieCrowdURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func privacyPolicyURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func eventsURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func mapsURLForEvent(event: Event) -> NSURL {
        fatalError("override me in spec!")
    }

    func codersForSandersURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func designersForSandersURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func feedbackFormURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func sandersForPresidentURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func donateFormURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func createEventURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func videoURL() -> NSURL {
        fatalError("override me in spec!")
    }

    func youtubeVideoURL(idenifier: String) -> NSURL {
        fatalError("override me in spec!")
    }

    func youtubeThumbnailURL(idenifier: String) -> NSURL {
        fatalError("override me in spec!")
    }

    func hostEventFormURL() -> NSURL { fatalError("override me in spec!") }
}
