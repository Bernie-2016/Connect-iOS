import CBGPromise

typealias IssuesPromise = Promise<[Issue], IssueRepositoryError>
typealias IssuesFuture = Future<[Issue], IssueRepositoryError>


protocol IssueService {
    func fetchIssues() -> IssuesFuture
}
