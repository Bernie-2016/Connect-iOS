@testable import Connect

class MockRadiusDataSource: NSObject, RadiusDataSource {
    var returnedCurrentMilesValue: Float = 42

    var currentMilesValue: Float {
        get {
            return returnedCurrentMilesValue
        }
    }

    var didConfirmSelection = false
    func confirmSelection() {
        didConfirmSelection = true
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
}
