import Foundation

typealias UpcomingVoterRegistrationsCompletionHandler = (Array<VoterRegistrationInfo>) -> Void

protocol UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler)
}

class StockUpcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler) {
        let voteRegistrations = [
            VoterRegistrationInfo(stateName: "California", url: NSURL(string: "http://registertovote.ca.gov/")!),
            // No online registration for the below
//            VoterRegistrationInfo(stateName: "New Jersey", url: NSURL(string: "http://www.state.nj.us/state/elections/voting-information.html")!),
//            VoterRegistrationInfo(stateName: "Montana", url: NSURL(string: "http://www.sos.mt.gov/elections/Vote/")!),
//            VoterRegistrationInfo(stateName: "Virgin Islands", url: NSURL(string: "http://www.vivote.gov/content/register-vote")!),
//            VoterRegistrationInfo(stateName: "North Dakota", url: NSURL(string: "https://vip.sos.nd.gov/PortalList.aspx")!),
//            VoterRegistrationInfo(stateName: "South Dakota", url: NSURL(string: "https://sdsos.gov/elections-voting/voting/register-to-vote/default.aspx")!),

        ]

        completionHandler(voteRegistrations)
    }
}
