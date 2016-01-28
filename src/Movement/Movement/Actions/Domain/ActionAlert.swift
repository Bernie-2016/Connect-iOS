import Foundation

struct ActionAlert {
    let title: String
}

extension ActionAlert: Equatable {}

func == (lhs: ActionAlert, rhs: ActionAlert) -> Bool {
    return lhs.title == rhs.title
}
