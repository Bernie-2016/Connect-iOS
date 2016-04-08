import Foundation

typealias TweetID = String
typealias ActionAlertIdentifier = String

struct ActionAlert {
    let identifier: ActionAlertIdentifier
    let title: String
    let body: String
    let shortDescription: String
    let date: String
    let targetURL: NSURL?
    let twitterURL: NSURL?
    let tweetID: TweetID?

    func shareURL() -> NSURL? {
        let isFBVideo = body.rangeOfString("fb-video", options: .RegularExpressionSearch) != nil

        if isFBVideo && targetURL != nil {
            return targetURL
        }

        return nil
    }
}

extension ActionAlert: Equatable {}

func == (lhs: ActionAlert, rhs: ActionAlert) -> Bool {
    return lhs.identifier == rhs.identifier
    && lhs.title == rhs.title
    && lhs.body == rhs.body
    && lhs.shortDescription == rhs.shortDescription
    && lhs.date == rhs.date
    && lhs.targetURL == rhs.targetURL
    && lhs.twitterURL == rhs.twitterURL
    && lhs.tweetID == rhs.tweetID
}

extension ActionAlert: Hashable {
    var hashValue: Int {
        get {
            var hash = identifier.hashValue ^ title.hashValue ^ body.hashValue ^ shortDescription.hashValue ^ date.hashValue
            if targetURL != nil { hash = hash ^ targetURL!.hashValue }
            if twitterURL != nil { hash = hash ^ twitterURL!.hashValue }
            if tweetID != nil { hash = hash ^ tweetID!.hashValue }

            return hash
        }
    }
}
