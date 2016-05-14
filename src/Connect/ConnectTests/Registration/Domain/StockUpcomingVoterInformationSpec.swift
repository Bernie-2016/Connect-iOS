import Quick
import Nimble

@testable import Connect

class StockUpcomingVoterRegistrationUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockUpcomingVoterRegistrationUseCase") {
            var subject: UpcomingVoterRegistrationUseCase!

            beforeEach {
                subject = StockUpcomingVoterRegistrationUseCase()
            }

            describe("fetching the list of upcoming states") {
                it("calls the completion handler with the correct voter information") {
                    var receivedVoterInfo: [VoterRegistrationInfo]?

                    subject.fetchUpcomingVoterRegistrations({ (voterInfo) in
                        receivedVoterInfo = voterInfo
                    })

                    expect(receivedVoterInfo!.count) == 9
                }
            }
        }
    }
}
