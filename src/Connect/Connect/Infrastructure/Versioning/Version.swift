struct Version {
    let minimumVersion: Int
    let updateURL: NSURL
}

extension Version: Equatable {}

func == (lhs: Version, rhs: Version) -> Bool {
    return lhs.minimumVersion == rhs.minimumVersion
        && lhs.updateURL == rhs.updateURL
}
