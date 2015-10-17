import Foundation

class ConcreteNewsItemDeserializer: NewsItemDeserializer {
    private let stringContentSanitizer: StringContentSanitizer

    init(stringContentSanitizer: StringContentSanitizer) {
        self.stringContentSanitizer = stringContentSanitizer
    }

    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
                                                            // TODO: inject a dateformatter.

        var newsItems = [NewsItem]()

        let hitsDictionary = jsonDictionary["hits"] as? NSDictionary;

        if (hitsDictionary == nil) {
            return newsItems
        }

        let newsItemDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;

        if (newsItemDictionaries == nil) {
            return newsItems
        }

        for newsItemDictionary: NSDictionary in newsItemDictionaries! {
            let sourceDictionary = newsItemDictionary["_source"] as? NSDictionary;

            if(sourceDictionary == nil) {
                continue;
            }

            var title = sourceDictionary!["title"] as? String

            var body = sourceDictionary!["body_html"] as? String
            let dateString = sourceDictionary!["created_at"] as? String
            let urlString = sourceDictionary!["url"] as? String

            if (title == nil) || (body == nil) || (dateString == nil) || (urlString == nil) {
                continue;
            }

            title = self.stringContentSanitizer.sanitizeString(title!)
//            body = self.stringContentSanitizer.sanitizeString(body!)

            let url = NSURL(string: urlString!)
            let date = dateFormatter.dateFromString(dateString!)

            if (url == nil) || (date == nil) {
                continue;
            }

            let imageURLString = sourceDictionary!["image_url"] as? String
            var imageURL : NSURL?

            if(imageURLString != nil) {
                imageURL = NSURL(string: imageURLString!)
            }

            let newsItem = NewsItem(title: title!, date: date!, body: body!, imageURL: imageURL, URL: url!)
            newsItems.append(newsItem);
        }

        return newsItems
    }
}
