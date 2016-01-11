import Foundation

class ConcreteIssueDeserializer: IssueDeserializer {
    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        var issues = [Issue]()

        guard let hitsDictionary = jsonDictionary["hits"] as? NSDictionary else { return issues }
        guard let issueDictionaries = hitsDictionary["hits"] as? Array<NSDictionary> else { return issues }

        for issueDictionary: NSDictionary in issueDictionaries {
            guard let sourceDictionary = issueDictionary["_source"] as? NSDictionary else { continue }
            guard let title = sourceDictionary["title"] as? String else { continue }
            guard let body = sourceDictionary["body"] as? String else { continue }
            guard let urlString = sourceDictionary["url"] as? String else { continue }
            guard let url = NSURL(string: urlString) else { continue }

            let imageURLString = sourceDictionary["image_url"] as? String
            var imageURL: NSURL?

            if imageURLString != nil {
                imageURL = NSURL(string: imageURLString!)
            }

            let issue = Issue(title: title, body: body, imageURL: imageURL, url: url)
            issues.append(issue)
        }

        return issues
    }
}
