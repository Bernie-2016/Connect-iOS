import Foundation

class ConcreteNewsItemDeserializer: NewsItemDeserializer {
    private let stringContentSanitizer: StringContentSanitizer
    private let dateFormatter: NSDateFormatter

    private let bannedBernieImageURLString = "https://s.bsd.net/bernie16/main/page/-/website/fb-share.png"

    init(stringContentSanitizer: StringContentSanitizer) {
        self.stringContentSanitizer = stringContentSanitizer
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
    }

    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        var newsItems = [NewsItem]()

        guard let hitsDictionary = jsonDictionary["hits"] as? NSDictionary else { return newsItems }
        guard let newsItemDictionaries = hitsDictionary["hits"] as? Array<NSDictionary> else { return newsItems }

        for newsItemDictionary: NSDictionary in newsItemDictionaries {
            guard let sourceDictionary = newsItemDictionary["_source"] as? NSDictionary else { continue }

            guard var title = sourceDictionary["title"] as? String else { continue }
            guard var body = sourceDictionary["body"] as? String else { continue }
            guard var excerpt = sourceDictionary["excerpt"] as? String else { continue }
            guard let dateString = sourceDictionary["created_at"] as? String else { continue }
            guard let urlString = sourceDictionary["url"] as? String else { continue }

            title = self.stringContentSanitizer.sanitizeString(title)
            body = self.stringContentSanitizer.sanitizeString(body)
            excerpt = self.stringContentSanitizer.sanitizeString(excerpt)

            guard let url = NSURL(string: urlString) else { continue }
            guard let date = dateFormatter.dateFromString(dateString) else { continue }

            let imageURLString = sourceDictionary["image_url"] as? String
            var imageURL: NSURL?

            if imageURLString != nil && imageURLString != bannedBernieImageURLString {
                imageURL = NSURL(string: imageURLString!)
            }

            let newsItem = NewsItem(title: title, date: date, body: body, excerpt: excerpt, imageURL: imageURL, url: url)
            newsItems.append(newsItem);
        }

        return newsItems
    }
}
