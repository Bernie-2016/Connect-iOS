import Quick
import Nimble

@testable import Connect

class StockAppVersionCompatibilityUseCaseSpec: QuickSpec {
    override func spec() {
        describe("StockAppVersionCompatibilityUseCase") {
            var subject: StockAppVersionCompatibilityUseCase!
            var versionRepository: FakeVersionRepository!
            var appVersionProvider: FakeAppVersionProvider!

            beforeEach {
                versionRepository = FakeVersionRepository()
                appVersionProvider = FakeAppVersionProvider()

                subject = StockAppVersionCompatibilityUseCase(
                    versionRepository: versionRepository,
                    appVersionProvider: appVersionProvider
                )
            }

            describe("checking app compatibility") {
                it("requests the current version from the repo") {
                    subject.checkCurrentAppVersion({ (updateURL) in

                    })

                    expect(versionRepository.didFetchCurrentVersion) == true
                }

                describe("when the version repo resolves its promise with a version") {
                    var receivedUpdateURL: NSURL?
                    var completionHandlerCalled: Bool!

                    let expectedURL = NSURL(string: "https://example.com/update")!
                    let version = Version(minimumVersion: 42, updateURL: expectedURL)

                    beforeEach {
                        completionHandlerCalled = false

                        subject.checkCurrentAppVersion({ (updateURL) in
                            completionHandlerCalled = true
                            receivedUpdateURL = updateURL
                        })
                    }

                    context("and the minimum version matches the current version of the app") {
                        it("does not call the completion handler") {
                            appVersionProvider.returnedInternalBuildNumber = 42

                            versionRepository.lastReturnedPromise!.resolve(version)

                            expect(completionHandlerCalled) == false
                        }
                    }

                    context("and the minimum version is older than the current version of the app") {
                        it("does not call the completion handler") {
                            appVersionProvider.returnedInternalBuildNumber = 43

                            versionRepository.lastReturnedPromise!.resolve(version)

                            expect(completionHandlerCalled) == false
                        }
                    }

                    context("and minimum version is newer than the current version of the app") {
                        it("calls the completion handler with the URL") {
                            appVersionProvider.returnedInternalBuildNumber = 41

                            versionRepository.lastReturnedPromise!.resolve(version)

                            expect(completionHandlerCalled) == true

                            expect(receivedUpdateURL) === expectedURL
                        }
                    }
                }

                describe("when the version repo rejects its promise with an error") {
                    var completionHandlerCalled: Bool!

                    beforeEach {
                        completionHandlerCalled = false

                        subject.checkCurrentAppVersion({ (updateURL) in
                            completionHandlerCalled = true
                        })
                    }

                    it("does not call the completion handler") {
                        let error = VersionRepositoryError.InvalidJSON(jsonObject: [])

                        versionRepository.lastReturnedPromise!.reject(error)

                        expect(completionHandlerCalled) == false
                    }
                }
            }
        }
    }
}

private class FakeVersionRepository: VersionRepository {
    var lastReturnedPromise: VersionPromise?
    var didFetchCurrentVersion = false

    func fetchCurrentVersion() -> VersionFuture {
        didFetchCurrentVersion = true
        lastReturnedPromise = VersionPromise()

        return lastReturnedPromise!.future
    }

}

private class FakeAppVersionProvider: AppVersionProvider {
    var returnedInternalBuildNumber = -1

    private func internalBuildNumber() -> Int {
        return returnedInternalBuildNumber
    }
}
