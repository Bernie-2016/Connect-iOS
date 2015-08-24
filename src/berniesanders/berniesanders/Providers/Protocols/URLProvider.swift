import Foundation

public protocol URLProvider {
    func issuesFeedURL() -> NSURL!
}