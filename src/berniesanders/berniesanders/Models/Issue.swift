import Foundation

class Issue {
    let title: String
    let body: String
    let imageURL: NSURL?
    let URL: NSURL

    init(title: String, body: String, imageURL: NSURL?, URL: NSURL) {
        self.title = title
        self.body = body
        self.imageURL = imageURL
        self.URL = URL
    }
}
