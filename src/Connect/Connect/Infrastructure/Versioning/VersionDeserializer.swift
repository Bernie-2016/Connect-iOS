enum VersionDeserializerError: ErrorType {
    case MissingAttribute(String)
}

extension VersionDeserializerError: Equatable {}

func == (lhs: VersionDeserializerError, rhs: VersionDeserializerError) -> Bool {
    switch (lhs, rhs) {
    case (.MissingAttribute(let lhsAttribute), .MissingAttribute(let rhsAttribute)):
        return lhsAttribute == rhsAttribute
    }
}

protocol VersionDeserializer {
    func deserializeVersion(jsonDictionary: Dictionary<String, AnyObject>) throws -> Version
}

class StockVersionDeserializer: VersionDeserializer {
    func deserializeVersion(jsonDictionary: Dictionary<String, AnyObject>) throws -> Version {

        guard let minimumVersion = jsonDictionary["minimum_version"] as? Int else { throw VersionDeserializerError.MissingAttribute("minimum_version") }

        guard let updateURLString = jsonDictionary["update_url"] as? String else { throw VersionDeserializerError.MissingAttribute("update_url") }
        guard let updateURL = NSURL(string: updateURLString) else { throw VersionDeserializerError.MissingAttribute("update_url") }

        let version = Version(minimumVersion: minimumVersion, updateURL: updateURL)

        return version
    }
}
