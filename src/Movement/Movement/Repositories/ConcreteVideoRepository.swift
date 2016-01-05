import Foundation
import BrightFutures
import Result

class ConcreteVideoRepository: VideoRepository {
    private let urlProvider: URLProvider
    private let jsonClient: JSONClient
    private let videoDeserializer: VideoDeserializer
    private let operationQueue: NSOperationQueue

    init(urlProvider: URLProvider,
        jsonClient: JSONClient,
        videoDeserializer: VideoDeserializer,
        operationQueue: NSOperationQueue) {
        self.urlProvider = urlProvider
        self.jsonClient = jsonClient
        self.videoDeserializer = videoDeserializer
        self.operationQueue = operationQueue
    }

    func fetchVideos() -> Future<Array<Video>, NSError> {
        let promise = Promise<Array<Video>, NSError>()

        let videoJSONFuture = self.jsonClient.JSONPromiseWithURL(self.urlProvider.videoURL(), method: "POST", bodyDictionary: self.HTTPBodyDictionary())

        videoJSONFuture.onSuccess { (deserializedObject) -> Void in
            guard let jsonDictionary = deserializedObject as? NSDictionary else {
                let incorrectObjectTypeError = NSError(domain: "ConcreteVideoRepository", code: -1, userInfo: nil)
                self.operationQueue.addOperationWithBlock({ () -> Void in
                    promise.failure(incorrectObjectTypeError)
                })
                return
            }

            let parsedVideos = self.videoDeserializer.deserializeVideos(jsonDictionary)

            self.operationQueue.addOperationWithBlock({ () -> Void in
                promise.success(parsedVideos as [Video])
            })
            }.onFailure { (receivedError) -> Void in
                self.operationQueue.addOperationWithBlock({ () -> Void in
                    promise.failure(receivedError)
                })
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
