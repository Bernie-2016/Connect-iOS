import Foundation

public class ConcreteNewsItemDeserializer : NewsItemDeserializer {
    public init() {
        
    }
    
    public func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // "2015-08-28T05:10:21"
                                                                 // TODO: inject a dateformatter.
        
        var newsItems = [NewsItem]()
        
        var hitsDictionary = jsonDictionary["hits"] as! NSDictionary;
        var newsItemDictionaries = hitsDictionary["hits"] as! Array<NSDictionary>;
        for(newsItemDictionary: NSDictionary) in newsItemDictionaries {
            var sourceDictionary = newsItemDictionary["_source"] as! NSDictionary;
            var title = sourceDictionary["title"] as! String
            var body = sourceDictionary["body"] as! String
            var pubDate = sourceDictionary["created_at"] as! String
            var date = dateFormatter.dateFromString(pubDate)!
            var imageURLString = sourceDictionary["image_url"] as! String
            var imageURL = NSURL(string: imageURLString)!
            var urlString = sourceDictionary["url"] as! String
            var url = NSURL(string: urlString)!
            
            var newsItem = NewsItem(title: title, date: date, body: body, imageURL: imageURL, url: url)
            newsItems.append(newsItem);
        }
        
        return newsItems
    }
}