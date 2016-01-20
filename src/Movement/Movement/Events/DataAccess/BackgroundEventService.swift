import Foundation

class BackgroundEventService: EventService {
    private let eventRepository: EventRepository
    private let workerQueue: NSOperationQueue
    private let resultQueue: NSOperationQueue

    init(eventRepository: EventRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.eventRepository = eventRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float) -> EventSearchResultFuture {
        let promise = EventSearchResultPromise()

        workerQueue.addOperationWithBlock {
            self.eventRepository.fetchEventsWithZipCode(zipCode, radiusMiles: radiusMiles, completion: { eventSearchResult -> Void in
                self.resultQueue.addOperationWithBlock {
                    promise.resolve(eventSearchResult)
                }
                }, error: { error in
                    self.resultQueue.addOperationWithBlock {
                        promise.reject(error)
                    }
            })

        }

        return promise.future
    }
}
