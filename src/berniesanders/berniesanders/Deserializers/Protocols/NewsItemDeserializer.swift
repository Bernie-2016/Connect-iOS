import Foundation

public protocol NewsItemDeserializer {
    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem>
}
