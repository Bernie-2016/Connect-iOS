import Foundation
import Ono

public protocol IssueDeserializer {
    func deserializeIssues(xmlDocument: ONOXMLDocument) -> Array<Issue>
}