import Foundation

protocol RadiusDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    var currentMilesValue: Float { get }
    var confirmedSelectedIndex: Int { get }

    func confirmSelection()
    func addObserver(observer: RadiusDataSourceObserver)
}

protocol RadiusDataSourceObserver :class {
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: Float)
}

class StockRadiusDataSource: NSObject, RadiusDataSource {
    var currentMilesValue: Float {
        get {
            return values[confirmedSelectedIndex]
        }
    }

    var confirmedSelectedIndex = 1
    private var selectedIndex = 1

    private let values: [Float] = [5, 10, 20, 50, 100, 250]
    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [RadiusDataSourceObserver] {
        return _observers.allObjects.flatMap { $0 as? RadiusDataSourceObserver }
    }


    func confirmSelection() {
        confirmedSelectedIndex = selectedIndex

        for observer in observers {
            observer.radiusDataSourceDidUpdateRadiusMiles(values[confirmedSelectedIndex])
        }
    }

    func addObserver(observer: RadiusDataSourceObserver) {
        _observers.addObject(observer)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSString.localizedStringWithFormat(NSLocalizedString("EventsSearchBar_pickerRadiusMiles %d", comment: ""), Int(values[row])) as String
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
}
