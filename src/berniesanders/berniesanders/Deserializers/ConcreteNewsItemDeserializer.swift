import Foundation

public class ConcreteNewsItemDeserializer : NewsItemDeserializer {
    public init() {
        
    }
    
    public func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem> {
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        // "2015-08-28T05:10:21.393Z"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        var newsItems = [NewsItem]()
        
        var hitsDictionary = jsonDictionary["hits"] as! NSDictionary;
        var newsItemDictionaries = hitsDictionary["hits"] as! Array<NSDictionary>;
        for(newsItemDictionary: NSDictionary) in newsItemDictionaries {
            var sourceDictionary = newsItemDictionary["_source"] as! NSDictionary;
            var title = sourceDictionary["title"] as! String
            var pubDate = sourceDictionary["published_time"] as! String
            var date = dateFormatter.dateFromString(pubDate)!
            
            var newsItem = NewsItem(title: title, date: date)
            newsItems.append(newsItem);
        }
        
        return newsItems
    }
}