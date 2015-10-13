import Foundation

protocol EventDeserializer {
    func deserializeEvents(jsonDictionary: NSDictionary) -> Array<Event>
}
