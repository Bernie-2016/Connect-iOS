import Foundation

public protocol URLProvider {
    func issuesFeedURL() -> NSURL!
    func newsFeedURL() -> NSURL!
    func bernieCrowdURL() -> NSURL!
}