import Foundation
import CoreLocation

protocol URLProvider {
    func newsFeedURL() -> NSURL
    func eventsURL() -> NSURL
    func privacyPolicyURL() -> NSURL
    func hostEventFormURL() -> NSURL
    func mapsURLForEvent(event: Event) -> NSURL
    func githubURL() -> NSURL
    func slackURL() -> NSURL
    func feedbackFormURL() -> NSURL
    func donateFormURL() -> NSURL
    func videoURL() -> NSURL
    func youtubeVideoURL(identifier: String) -> NSURL
    func youtubeThumbnailURL(identifier: String) -> NSURL
    func actionAlertsURL() -> NSURL
    func twitterShareURL(urlToShare: NSURL) -> NSURL
    func retweetURL(tweetID: TweetID) -> NSURL
    func actionAlertURL(identifier: ActionAlertIdentifier) -> NSURL
    func versionURL() -> NSURL
}
