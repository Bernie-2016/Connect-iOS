@testable import Connect

class FakeZipCodeValidator: ZipCodeValidator {
    var lastReceivedZipCode: NSString!
    var returnedValidationResult = true

    func reset() {
        lastReceivedZipCode = nil
    }

    func validate(zip: String) -> Bool {
        lastReceivedZipCode = zip
        return returnedValidationResult
    }
}
