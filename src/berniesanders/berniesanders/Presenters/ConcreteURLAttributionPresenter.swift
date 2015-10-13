import Foundation

class ConcreteURLAttributionPresenter: URLAttributionPresenter {
    init() {}

    func attributionTextForURL(url: NSURL) -> String {
        let hostname = url.host!
        return String(format: NSLocalizedString("Global_urlAttribution", comment: ""), hostname)
    }
}
