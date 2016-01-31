import Foundation

struct ActionAlert {
    let title: String
    let body: String
    let date: String
    let targetURL: NSURL?
    let twitterURL: NSURL?
    let tweetID: String?
}

extension ActionAlert: Equatable {}

func == (lhs: ActionAlert, rhs: ActionAlert) -> Bool {
    return lhs.title == rhs.title
    && lhs.body == rhs.body
    && lhs.date == rhs.date
}
