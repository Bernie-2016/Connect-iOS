import UIKit

// swiftlint:disable comma
class ConcreteStringContentSanitizer: StringContentSanitizer {
    init() {}

    func sanitizeString(string: String) -> String {
        var sanitizedString = decodeHTMLEntities(string)
        sanitizedString = removeReadTheRest(sanitizedString)
        sanitizedString = removeClickhere(sanitizedString)
        sanitizedString = removeIshere(sanitizedString)
        sanitizedString = removeResthere(sanitizedString)
        sanitizedString = removeArticlehere(sanitizedString)
        sanitizedString = removeHere(sanitizedString)
        sanitizedString = removeOpEdhere(sanitizedString)
        sanitizedString = removeEmailProtected(sanitizedString)

        return sanitizedString
    }

    // MARK: Private

    func decodeHTMLEntities(string: String) -> String {
        return string.gtm_stringByUnescapingFromHTML()
    }

    func removeTextMatchingRegEx(string: String, regEx: String) -> String {
        let regEx = try? NSRegularExpression(pattern: regEx, options: [])
        return regEx!.stringByReplacingMatchesInString(string, options: [], range: NSMakeRange(0, string.characters.count), withTemplate: "")
    }

    func removeReadTheRest(string: String) -> String {
        return removeTextMatchingRegEx(string, regEx: "(Read the rest at.+\\.)")
    }

    func removeClickhere(string: String) -> String {
        return removeTextMatchingRegEx(string, regEx: " ([’*`*'*,*\"*\\w+\\s+]+ clickhere\\.)")
    }

    func removeIshere (string: String) -> String {
        let sanitizedString = removeTextMatchingRegEx(string, regEx:"(\\([’*`*'*,*\"*\\w+\\s+]+ ishere\\.\\))")
        return removeTextMatchingRegEx(sanitizedString, regEx:"[’*`*'*,*\"*\\w+\\s+]+ishere\\.")
    }

    func removeResthere (string: String) -> String {
        let sanitizedString = removeTextMatchingRegEx(string, regEx:"(’*`*'*,*\"*\\([\\w+\\s+]+ resthere\\.\\))")
        return removeTextMatchingRegEx(sanitizedString, regEx:"[’*`*'*,*\"*\\w+\\s+]+resthere\\.")
    }

    func removeArticlehere (string: String) -> String {
        let sanitizedString = removeTextMatchingRegEx(string, regEx: "(’*`*'*,*\"*\\([\\w+\\s+]+ articlehere\\.\\))")
        return removeTextMatchingRegEx(sanitizedString, regEx: "[’*`*'*,*\"*\\w+\\s+]+articlehere\\.")
    }

    func removeHere(string: String) -> String {
        let sanitizedString = removeTextMatchingRegEx(string, regEx: "[’*`*'*,*\"*\\w+\\s+]+ here:\\n")
        return removeTextMatchingRegEx(sanitizedString, regEx: "[’*`*'*,*\"*\\w+\\s+]+ here:\\z")
    }

    func removeOpEdhere(string: String) -> String {
        let sanitizedString = removeTextMatchingRegEx(string, regEx: "(’*`*'*,*\"*\\([\\w+\\s+]+ op-edhere\\.\\))")
        return removeTextMatchingRegEx(sanitizedString, regEx: "[’*`*'*,*\"*\\w+\\s+]+op-edhere\\.")
    }

    func removeEmailProtected(string: String) -> String {
        return removeTextMatchingRegEx(string, regEx: "\\[email protected\\].+\\*/\\.")
    }
}
// swiftlint:enable comma
