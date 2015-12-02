import Foundation

protocol NewsArticleDeserializer {
    func deserializeNewsArticles(jsonDictionary: NSDictionary) -> [NewsArticle]
}
