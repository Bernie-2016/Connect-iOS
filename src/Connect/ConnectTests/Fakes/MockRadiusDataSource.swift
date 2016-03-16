@testable import Connect

class MockRadiusDataSource: NSObject, RadiusDataSource {
    var returnedCurrentMilesValue: Float = 42

    var currentMilesValue: Float {
        get {
            return returnedCurrentMilesValue
        }
    }
    var confirmedSelectedIndex: Int {
        get {
            return 0
        }
    }

    var didConfirmSelection = false
    func confirmSelection() {
        didConfirmSelection = true
    }

    var observers: [RadiusDataSourceObserver] = []
    func addObserver(observer: RadiusDataSourceObserver) {
        observers.append(observer)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "TBD"
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }

    func simulateConfirmingSelection(radiusMiles: Float) {
        for observer in observers {
            observer.radiusDataSourceDidUpdateRadiusMiles(radiusMiles)
        }
    }
}
