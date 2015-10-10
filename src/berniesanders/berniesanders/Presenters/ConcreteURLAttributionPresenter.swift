import Foundation

public class ConcreteURLAttributionPresenter: URLAttributionPresenter {
    public init() {}

    public func attributionTextForURL(url: NSURL) -> String {
        let hostname = url.host!
        return String(format: NSLocalizedString("Global_urlAttribution", comment: ""), hostname)
    }
}
