import Foundation

public protocol URLAttributionPresenter {
    func attributionTextForURL(url: NSURL) -> String
}
