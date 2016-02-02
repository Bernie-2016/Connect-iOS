import Foundation

typealias TweetID = String
typealias ActionAlertIdentifier = String

struct ActionAlert {
    let identifier: ActionAlertIdentifier
    let title: String
    let body: String
    let date: String
    let targetURL: NSURL?
    let twitterURL: NSURL?
    let tweetID: TweetID?
}

extension ActionAlert: Equatable {}

func == (lhs: ActionAlert, rhs: ActionAlert) -> Bool {
    return lhs.identifier == rhs.identifier
    && lhs.title == rhs.title
    && lhs.body == rhs.body
    && lhs.date == rhs.date
    && lhs.targetURL == rhs.targetURL
    && lhs.twitterURL == rhs.twitterURL
    && lhs.tweetID == rhs.tweetID
}
