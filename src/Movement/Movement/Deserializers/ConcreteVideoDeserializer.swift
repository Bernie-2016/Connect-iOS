import Foundation

class ConcreteVideoDeserializer: VideoDeserializer {
    private let dateFormatter: NSDateFormatter

    init(
        ) {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"  // "2015-08-28T05:10:21Z"
    }

    func deserializeVideos(jsonDictionary: NSDictionary) -> Array<Video> {
        var videos = [Video]()

        guard let hitsDictionary = jsonDictionary["hits"] as? NSDictionary else { return videos }
        guard let videoDictionaries = hitsDictionary["hits"] as? Array<NSDictionary> else { return videos }

        for videoDictionary: NSDictionary in videoDictionaries {
            guard let sourceDictionary = videoDictionary["_source"] as? NSDictionary else { continue }
            guard let title = sourceDictionary["title"] as? String else { continue }
            guard let description = sourceDictionary["description"] as? String else { continue }
            guard let identifier = sourceDictionary["video_id"] as? String else { continue }
            guard let dateString = sourceDictionary["timestamp_publish"] as? String else { continue }

            guard let date = dateFormatter.dateFromString(dateString) else { continue }

            let video = Video(title: title, date: date, identifier: identifier, description: description)
            videos.append(video)
        }

        return videos

    }
}
