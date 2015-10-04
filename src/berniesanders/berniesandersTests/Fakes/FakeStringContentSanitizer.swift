import Foundation
import berniesanders

class FakeStringContentSanitizer: StringContentSanitizer {
    internal init() {}
    
    func sanitizeString(string: String) -> String {
        return "\(string) SANITIZED!"
    }
}
