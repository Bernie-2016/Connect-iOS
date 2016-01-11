import Foundation
import CBGPromise

class ConcreteVideoRepository: VideoRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let videoDeserializer: VideoDeserializer

    init(urlProvider: URLProvider,
        jsonClient: JSONClient,
        videoDeserializer: VideoDeserializer) {
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.videoDeserializer = videoDeserializer
    }

    func fetchVideos() -> Future<Array<Video>, NSError> {
        let promise = Promise<Array<Video>, NSError>()

        let videoJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.videoURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        videoJSONFuture.then { deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NSError(domain: "ConcreteVideoRepository", code: -1, userInfo: nil)
                promise.reject(incorrectObjectTypeError)

                return
            }

            let parsedVideos = self.videoDeserializer.deserializeVideos(jsonDictionary)

            promise.resolve(parsedVideos as [Video])
        }


        videoJSONFuture.error { receivedError in
            promise.reject(receivedError)
        }

        return promise.future
    }

    // MARK: Private

    func HTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 5,
            "_source": ["title", "videoId", "description", "created_at"],
            "sort": [
                "created_at": ["order": "desc"]
            ]
        ]
    }
}
