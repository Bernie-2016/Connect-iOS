protocol AppVersionCompatibilityUseCase {
    func checkCurrentAppVersion(
        currentVersionNotSupported: (updateURL: NSURL) -> ()
    )
}

class StockAppVersionCompatibilityUseCase: AppVersionCompatibilityUseCase {
    private let versionRepository: VersionRepository
    private let appVersionProvider: AppVersionProvider

    init(
        versionRepository: VersionRepository,
        appVersionProvider: AppVersionProvider
        ) {
        self.versionRepository = versionRepository
        self.appVersionProvider = appVersionProvider
    }

    func checkCurrentAppVersion(currentVersionNotSupported: (updateURL: NSURL) -> ()) {
        versionRepository.fetchCurrentVersion()
            .then { (version) in
                if self.appVersionProvider.internalBuildNumber() < version.minimumVersion {
                    currentVersionNotSupported(updateURL: version.updateURL)
                }
        }
    }
}
