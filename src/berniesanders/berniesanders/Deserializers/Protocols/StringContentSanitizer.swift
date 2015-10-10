import Foundation

public protocol StringContentSanitizer {
    func sanitizeString(string: String) -> String
}
