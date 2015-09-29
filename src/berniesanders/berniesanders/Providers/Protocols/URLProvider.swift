import Foundation
import CoreLocation

public protocol URLProvider {
    func issuesFeedURL() -> NSURL!
    func newsFeedURL() -> NSURL!
    func bernieCrowdURL() -> NSURL!
    func privacyPolicyURL() -> NSURL!
    func eventsURL() -> NSURL!
    func mapsURLForEvent(event: Event) -> NSURL!
}