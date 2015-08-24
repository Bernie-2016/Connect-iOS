import Foundation
import Ono

public class ConcreteNewsItemDeserializer : NewsItemDeserializer {
    public init() {
        
    }
    
    public func deserializeNewsItems(xmlDocument: ONOXMLDocument) -> Array<NewsItem> {
        var newsItems = [NewsItem]()
        
                xmlDocument.enumerateElementsWithXPath("//item", usingBlock: { (itemElement, index, stop) -> Void in
                    var title = itemElement.firstChildWithXPath("title").stringValue()
                    var pubDate = itemElement.firstChildWithXPath("pubDate").stringValue()
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.timeZone = NSTimeZone(name: "UTC")
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss +0000"
                    var date = dateFormatter.dateFromString(pubDate)
                    
                    newsItems.append(NewsItem(title: title, date: date!))
                })
        
        return newsItems
    }
}