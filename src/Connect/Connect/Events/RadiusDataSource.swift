import Foundation

protocol RadiusDataSource {
    var currentMilesValue: Float { get }
}

class StockRadiusDataSource: RadiusDataSource {
    var currentMilesValue: Float {
        get {
            return 10.0
        }
    }
}
