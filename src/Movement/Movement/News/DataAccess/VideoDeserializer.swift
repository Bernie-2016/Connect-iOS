import Foundation

protocol VideoDeserializer {
    func deserializeVideos(jsonDictionary: NSDictionary) -> Array<Video>
}
