import CBGPromise

typealias IssuesPromise = Promise<[Issue], NSError>
typealias IssuesFuture = Future<[Issue], NSError>


protocol IssueService {
    func fetchIssues() -> IssuesFuture
}
