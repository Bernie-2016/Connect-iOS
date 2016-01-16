import Foundation
import CoreLocation

protocol URLProvider {
    func issuesFeedURL() -> NSURL
    func newsFeedURL() -> NSURL
    func bernieCrowdURL() -> NSURL
    func privacyPolicyURL() -> NSURL
    func eventsURL() -> NSURL
    func mapsURLForEvent(event: Event) -> NSURL
    func codersForSandersURL() -> NSURL
    func designersForSandersURL() -> NSURL
    func sandersForPresidentURL() -> NSURL
    func feedbackFormURL() -> NSURL
    func donateFormURL() -> NSURL
    func hostEventFormURL() -> NSURL
    func createEventURL() -> NSURL
    func videoURL() -> NSURL
    func youtubeVideoURL(identifier: String) -> NSURL
    func youtubeThumbnailURL(identifier: String) -> NSURL
}
