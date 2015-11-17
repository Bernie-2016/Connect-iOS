import Foundation
@testable import Movement

class FakeStringContentSanitizer: StringContentSanitizer {
    internal init() {}

    func sanitizeString(string: String) -> String {
        return "\(string) SANITIZED!"
    }
}
