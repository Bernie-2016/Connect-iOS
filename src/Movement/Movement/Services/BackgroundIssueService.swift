class BackgroundIssueService: IssueService {
    let issueRepository: IssueRepository
    let workerQueue: NSOperationQueue
    let resultQueue: NSOperationQueue

    init(issueRepository: IssueRepository, workerQueue: NSOperationQueue, resultQueue: NSOperationQueue) {
        self.issueRepository = issueRepository
        self.workerQueue = workerQueue
        self.resultQueue = resultQueue
    }

    func fetchIssues() -> IssuesFuture {
        let promise = IssuesPromise()

        workerQueue.addOperationWithBlock {
            self.issueRepository.fetchIssues({ issues in
                self.resultQueue.addOperationWithBlock({
                    promise.resolve(issues)
                })
                }, error: { error in
                    self.resultQueue.addOperationWithBlock({
                        promise.reject(error)
                    })

            })
        }

        return promise.future
    }
}
