import Foundation

public protocol EventDeserializer {
    func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event>
}
