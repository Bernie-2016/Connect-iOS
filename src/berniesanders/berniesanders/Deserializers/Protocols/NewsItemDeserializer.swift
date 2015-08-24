import Foundation
import Ono

public protocol NewsItemDeserializer {
    func deserializeNewsItems(xmlDocument: ONOXMLDocument) -> Array<NewsItem>
}