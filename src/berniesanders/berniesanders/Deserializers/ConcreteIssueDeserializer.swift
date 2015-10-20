import Foundation

class ConcreteIssueDeserializer: IssueDeserializer {
    private let stringContentSanitizer: StringContentSanitizer

    init(stringContentSanitizer: StringContentSanitizer) {
        self.stringContentSanitizer = stringContentSanitizer
    }

    func deserializeIssues(jsonDictionary: NSDictionary) -> Array<Issue> {
        var issues = [Issue]()

        let hitsDictionary = jsonDictionary["hits"] as? NSDictionary;

        if hitsDictionary == nil {
            return issues
        }

        let issueDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;

        if issueDictionaries == nil {
            return issues
        }

        for issueDictionary: NSDictionary in issueDictionaries! {
            let sourceDictionary = issueDictionary["_source"] as? NSDictionary;

            if sourceDictionary == nil {
                continue
            }

            var title = sourceDictionary!["title"] as? String
            var body = sourceDictionary!["body"] as? String
            let urlString = sourceDictionary!["url"] as? String

            if title == nil || body == nil || urlString == nil {
                continue
            }

            title = self.stringContentSanitizer.sanitizeString(title!)
            body = self.stringContentSanitizer.sanitizeString(body!)

            let url = NSURL(string: urlString!)
            if url == nil {
                continue;
            }

            let imageURLString = sourceDictionary!["image_url"] as? String
            var imageURL: NSURL?

            if imageURLString != nil {
                imageURL = NSURL(string: imageURLString!)
            }

            let issue = Issue(title: title!, body: body!, imageURL: imageURL, url: url!)
            issues.append(issue);
        }

        return issues
    }
}
