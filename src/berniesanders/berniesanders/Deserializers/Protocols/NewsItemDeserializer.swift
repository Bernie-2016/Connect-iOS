import Foundation

protocol NewsItemDeserializer {
    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem>
}
