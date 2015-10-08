import Foundation
import CoreLocation

public protocol URLProvider {
    func issuesFeedURL() -> NSURL!
    func newsFeedURL() -> NSURL!
    func bernieCrowdURL() -> NSURL!
    func privacyPolicyURL() -> NSURL!
    func eventsURL() -> NSURL!
    func mapsURLForEvent(event: Event) -> NSURL!
    func codersForSandersURL() -> NSURL!
    func designersForSandersURL() -> NSURL!
    func sandersForPresidentURL() -> NSURL!
    func feedbackFormURL() -> NSURL!
    func donateFormURL() -> NSURL!
}