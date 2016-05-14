import Foundation

typealias UpcomingVoterRegistrationsCompletionHandler = (Array<VoterRegistrationInfo>) -> Void

protocol UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler)
}

class StockUpcomingVoterRegistrationUseCase: UpcomingVoterRegistrationUseCase {
    func fetchUpcomingVoterRegistrations(completionHandler: UpcomingVoterRegistrationsCompletionHandler) {
        let voteRegistrations = [
            VoterRegistrationInfo(stateName: "Kentucky", url: NSURL(string: "https://vrsws.sos.ky.gov/ovrweb/")!),
            VoterRegistrationInfo(stateName: "Oregon", url: NSURL(string: "https://secure.sos.state.or.us/orestar/vr/register.do?lang=eng&source=SOS")!),
            VoterRegistrationInfo(stateName: "California", url: NSURL(string: "http://registertovote.ca.gov/")!),
            VoterRegistrationInfo(stateName: "New Mexico", url: NSURL(string: "https://portal.sos.state.nm.us/OVR/%28S%28od4445h5uj2f5tyucvvhszdf%29%29/WebPages/InstructionsStep1.aspx")!),
            VoterRegistrationInfo(stateName: "New Jersey", url: NSURL(string: "http://www.state.nj.us/state/elections/voting-information.html")!),
            VoterRegistrationInfo(stateName: "Montana", url: NSURL(string: "http://www.dmv.org/mt-montana/voter-registration.php")!),
            VoterRegistrationInfo(stateName: "Virgin Islands", url: NSURL(string: "http://www.vivote.gov/content/register-vote")!),
            VoterRegistrationInfo(stateName: "North Dakota", url: NSURL(string: "http://www.dmv.org/nd-north-dakota/voter-registration.php")!),
            VoterRegistrationInfo(stateName: "South Dakota", url: NSURL(string: "https://sdsos.gov/elections-voting/voting/register-to-vote/default.aspx")!),

        ]

        completionHandler(voteRegistrations)
    }
}
