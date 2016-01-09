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
                        issueRepository.lastCompletionBlock!([expectedIssue])

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
                        let future = subject.fetchIssues()
                        workerQueue.lastReceivedBlock()

                        let expectedError = NSError(domain: "boo", code: 123, userInfo: nil)

                        issueRepository.lastErrorBlock!(expectedError)

                        expect(future.error).to(beNil())

                        resultQueue.lastReceivedBlock()

                        expect(future.error).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}

private class FakeIssueRepository: IssueRepository {
    var lastCompletionBlock: ((Array<Issue>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchIssuesCalled: Bool = false

    func fetchIssues(completion: (Array<Issue>) -> Void, error: (NSError) -> Void) {
        self.fetchIssuesCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}
