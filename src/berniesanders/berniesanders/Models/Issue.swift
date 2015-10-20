import Foundation

class Issue {
    let title: String
    let body: String
    let imageURL: NSURL?
    let url: NSURL

    init(title: String, body: String, imageURL: NSURL?, url: NSURL) {
        self.title = title
        self.body = body
        self.imageURL = imageURL
        self.url = url
    }
}
