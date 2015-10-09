import Foundation

public class ConcreteNewsItemDeserializer: NewsItemDeserializer {
    let stringContentSanitizer: StringContentSanitizer

    public init(stringContentSanitizer: StringContentSanitizer) {
        self.stringContentSanitizer = stringContentSanitizer
    }
    
    public func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
                                                            // TODO: inject a dateformatter.
        
        var newsItems = [NewsItem]()
        
        var hitsDictionary = jsonDictionary["hits"] as? NSDictionary;

        if (hitsDictionary == nil) {
            return newsItems
        }
        
        var newsItemDictionaries = hitsDictionary!["hits"] as? Array<NSDictionary>;
        
        if (newsItemDictionaries == nil) {
            return newsItems
        }
        
        for(newsItemDictionary: NSDictionary) in newsItemDictionaries! {
            var sourceDictionary = newsItemDictionary["_source"] as? NSDictionary;

            if(sourceDictionary == nil) {
                continue;
            }
            
            var title = sourceDictionary!["title"] as? String

            var body = sourceDictionary!["body"] as? String
            var dateString = sourceDictionary!["created_at"] as? String
            var urlString = sourceDictionary!["url"] as? String
            
            if (title == nil) || (body == nil) || (dateString == nil) || (urlString == nil) {
                continue;
            }
            
            title = self.stringContentSanitizer.sanitizeString(title!)
            body = self.stringContentSanitizer.sanitizeString(body!)
            
            var url = NSURL(string: urlString!)
            var date = dateFormatter.dateFromString(dateString!)
            
            if (url == nil) || (date == nil) {
                continue;
            }

            var imageURLString = sourceDictionary!["image_url"] as? String
            var imageURL : NSURL?
            
            if(imageURLString != nil) {
                imageURL = NSURL(string: imageURLString!)
            }
            
            var newsItem = NewsItem(title: title!, date: date!, body: body!, imageURL: imageURL, URL: url!)
            newsItems.append(newsItem);
        }
        
        return newsItems
    }
}