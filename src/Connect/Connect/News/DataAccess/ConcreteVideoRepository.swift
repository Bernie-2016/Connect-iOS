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

    func fetchVideos() -> VideosFuture {
        let promise = VideosPromise()

        let videoJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.videoURL(), method: "POST", bodyDictionary: HTTPBodyDictionary())

        videoJSONFuture.then { deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = VideoRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedVideos = self.videoDeserializer.deserializeVideos(jsonDictionary)

            promise.resolve(parsedVideos as [Video])
        }


        videoJSONFuture.error { receivedError in
            let jsonClientError = VideoRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(jsonClientError)
        }

        return promise.future
    }

    func fetchVideo(identifier: VideoIdentifier) -> VideoFuture {
        let promise = VideoPromise()

        let videoFuture = self.jsonClient.JSONPromiseWithURL(urlProvider.videoURL(), method: "POST", bodyDictionary: VideoHTTPBodyDictionary(identifier))

        videoFuture.then({ deserializedObject in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = VideoRepositoryError.InvalidJSON(jsonObject: deserializedObject)
                promise.reject(incorrectObjectTypeError)
                return
            }

            let parsedVideos = self.videoDeserializer.deserializeVideos(jsonDictionary)

            guard let video = parsedVideos.first else {
                let noMatchingVideoError = VideoRepositoryError.NoMatchingVideo(identifier: identifier)
                promise.reject(noMatchingVideoError)
                return
            }
            promise.resolve(video)
        })

        videoFuture.error { receivedError in
            let error = VideoRepositoryError.ErrorInJSONClient(error: receivedError)
            promise.reject(error)
        }

        return promise.future
    }

    // MARK: Private

    private func HTTPBodyDictionary() -> NSDictionary {
        return [
            "from": 0, "size": 5,
            "_source": [ "title", "video_id", "description", "timestamp_publish" ],
            "sort": [
                "timestamp_publish": ["order": "desc", "ignore_unmapped": true]
            ]
        ]
    }

    private func VideoHTTPBodyDictionary(identifier: VideoIdentifier) -> NSDictionary {
        return [
            "from": 0, "size": 1,
            "_source": ["title", "video_id", "description", "timestamp_publish"],
            "filter": [
                "term": [
                    "_id": identifier,
                ]
            ]
        ]
    }
}
