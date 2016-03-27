protocol AppVersionProvider {
    func internalBuildNumber() -> Int
}

class StockAppVersionProvider: AppVersionProvider {
    func internalBuildNumber() -> Int {
        let internalBuildNumberString  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String  ?? "-1"

        let internalBuildNumber = Int(internalBuildNumberString)

        return internalBuildNumber!
    }
}
