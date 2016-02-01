import Foundation

typealias TweetID = String

struct ActionAlert {
    let title: String
    let body: String
    let date: String
    let targetURL: NSURL?
    let twitterURL: NSURL?
    let tweetID: TweetID?
}

extension ActionAlert: Equatable {}

func == (lhs: ActionAlert, rhs: ActionAlert) -> Bool {
    return lhs.title == rhs.title
    && lhs.body == rhs.body
    && lhs.date == rhs.date
}
