import Foundation
@testable import berniesanders

class FakeURLAttributionPresenter : URLAttributionPresenter {
    var lastPresentedURL : NSURL!
    let returnedText = "Some fake attribution text"

    func attributionTextForURL(url: NSURL) -> String {
        lastPresentedURL = url
        return returnedText
    }
}
