@testable import Connect

class MockRadiusDataSource: RadiusDataSource {
    var returnedCurrentMilesValue: Float = 42

    var currentMilesValue: Float {
        get {
            return returnedCurrentMilesValue
        }
    }
}
