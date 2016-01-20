import Quick
import Nimble

@testable import Movement

class BackgroundIssueServiceSpec: QuickSpec {
    override func spec() {
        describe("BackgroundIssueService") {
            var subject: IssueService!
            var issueRepository: FakeIssueRepository!
            var workerQueue: FakeOperationQueue!
            var resultQueue: FakeOperationQueue!


            beforeEach {
                issueRepository = FakeIssueRepository()
                workerQueue = FakeOperationQueue()
                resultQueue = FakeOperationQueue()

                subject = BackgroundIssueService(issueRepository: issueRepository, workerQueue: workerQueue, resultQueue: resultQueue)
            }

            describe("fetching issues") {
                it("makes a request to the issue repository on the worker queue") {
                    subject.fetchIssues()

                    expect(issueRepository.fetchIssuesCalled).to(beFalse())

                    workerQueue.lastReceivedBlock()

                    expect(issueRepository.fetchIssuesCalled).to(beTrue())
                }

                context("when the issue repo calls the completion handler") {
                    it("resolves the promise on the result queue with the issues") {
                        let future = subject.fetchIssues()
                        workerQueue.lastReceivedBlock()

                        let expectedIssue = TestUtils.issue()
                        issueRepository.lastReturnedPromise.resolve([expectedIssue])

                        expect(future.value).to(beNil())

                        resultQueue.lastReceivedBlock()

                        let result = future.value!
                        expect(result.count).to(equal(1))
                        let issue = result.first

                        expect(issue).to(beIdenticalTo(expectedIssue))
                    }
                }

                context("when the issue repo calls the error handler") {
                    it("resolves the promise on the result queue with the error") {
                        let badObj = "wat"
                        let expectedError = IssueRepositoryError.InvalidJSON(jsonObject: badObj)

                        let future = subject.fetchIssues()
                        workerQueue.lastReceivedBlock()

                        issueRepository.lastReturnedPromise.reject(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        switch(future.error!) {
                        case IssueRepositoryError.InvalidJSON(let jsonObject):
                            expect((jsonObject as! String)).to(equal("wat"))
                        default:
                            fail("unexpected error type")
                        }
                    }
                }
            }
        }
    }
}

private class FakeIssueRepository: IssueRepository {
    var lastReturnedPromise: IssuesPromise!
    var fetchIssuesCalled: Bool = false

    func fetchIssues() -> IssuesFuture {
        lastReturnedPromise = IssuesPromise()
        self.fetchIssuesCalled = true
        return lastReturnedPromise.future
    }
}
