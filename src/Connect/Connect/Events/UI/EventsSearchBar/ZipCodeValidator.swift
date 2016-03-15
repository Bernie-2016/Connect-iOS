import Foundation
import CoreLocation

protocol ZipCodeValidator {
    func validate(zipCode: String) -> Bool
}

class StockZipCodeValidator: ZipCodeValidator {
    func validate(zipCode: String) -> Bool {
        var zipCodeIsValid = true

        if zipCode.characters.count != 5 {
            zipCodeIsValid = false
        }

        if Double(zipCode) == nil {
            zipCodeIsValid = false
        }

        return zipCodeIsValid
    }
}
