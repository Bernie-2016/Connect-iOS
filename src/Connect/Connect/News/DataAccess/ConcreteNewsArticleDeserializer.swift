import Foundation

class ConcreteNewsArticleDeserializer: NewsArticleDeserializer {
    private let dateFormatter: NSDateFormatter

    private let bannedBernieImageURLString = "https://s.bsd.net/bernie16/main/page/-/website/fb-share.png"

    init() {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"  // "2015-08-28T05:10:21+00:00"
    }

    func deserializeNewsArticles(jsonDictionary: NSDictionary) -> [NewsArticle] {
        var newsArticles = [NewsArticle]()

        guard let hitsDictionary = jsonDictionary["hits"] as? NSDictionary else { return newsArticles }
        guard let newsArticleDictionaries = hitsDictionary["hits"] as? Array<NSDictionary> else { return newsArticles }

        for newsArticleDictionary: NSDictionary in newsArticleDictionaries {
            guard let sourceDictionary = newsArticleDictionary["_source"] as? NSDictionary else { continue }
            guard let title = sourceDictionary["title"] as? String else { continue }
            guard let body = sourceDictionary["body_markdown"] as? String else { continue }
            guard let excerpt = sourceDictionary["excerpt"] as? String else { continue }
            guard let dateString = sourceDictionary["timestamp_publish"] as? String else { continue }

            guard let urlString = sourceDictionary["url"] as? String else { continue }
            guard let url = NSURL(string: urlString) else { continue }
            guard let date = dateFormatter.dateFromString(dateString) else { continue }

            let imageURLString = sourceDictionary["image_url"] as? String
            var imageURL: NSURL?

            if imageURLString != nil && imageURLString?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 && imageURLString != bannedBernieImageURLString {
                imageURL = NSURL(string: imageURLString!)
            }

            let newsArticle = NewsArticle(title: title, date: date, body: body, excerpt: excerpt, imageURL: imageURL, url: url)
            newsArticles.append(newsArticle)
        }

        return newsArticles
    }
}
