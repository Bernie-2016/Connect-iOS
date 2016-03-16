import Foundation

protocol RadiusDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    var currentMilesValue: Float { get }
    func confirmSelection()
}

class StockRadiusDataSource: NSObject, RadiusDataSource {
    var currentMilesValue: Float {
        get {
            return 10.0
        }
    }

    func confirmSelection() {

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
