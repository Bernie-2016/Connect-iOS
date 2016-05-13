import Foundation

typealias UpcomingVoterRegistrationsCompletionHandler = (Array<VoterRegistrationInfo>) -> Void

protocol UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler)
}

class StockUpcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler) {
        let voteRegistrations = [
            VoterRegistrationInfo(stateName: "Alabama", url: NSURL(string: "https://www.alabamavotes.gov/olvr/default.aspx")!),
                              VoterRegistrationInfo(stateName: "California", url: NSURL(string: "http://registertovote.ca.gov/")!)
        ]

        completionHandler(voteRegistrations)
    }
}
