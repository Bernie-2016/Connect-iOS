import Foundation
import KSDeferred

public protocol XMLClient {
    func fetchXMLDocumentWithURL(url: NSURL) -> KSPromise
}