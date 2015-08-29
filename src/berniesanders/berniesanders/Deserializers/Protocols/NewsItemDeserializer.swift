import Foundation
import Ono

public protocol NewsItemDeserializer {
    func deserializeNewsItems(jsonDictionary: NSDictionary) -> Array<NewsItem>
}