import Foundation

protocol NewsArticleControllerProvider {
    func provideInstanceWithNewsArticle(newsArticle: NewsArticle) -> NewsArticleController
}
