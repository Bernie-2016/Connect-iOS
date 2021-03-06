import Foundation

typealias DistanceMiles = Float

protocol RadiusDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    var currentMilesValue: DistanceMiles { get }
    var confirmedSelectedIndex: Int { get }

    func resetToDefaultSearchRadius()
    func confirmSelection()
    func addObserver(observer: RadiusDataSourceObserver)
}

protocol RadiusDataSourceObserver :class {
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: DistanceMiles)
}

class StockRadiusDataSource: NSObject, RadiusDataSource {
    var currentMilesValue: DistanceMiles {
        get {
            return values[confirmedSelectedIndex]
        }
    }

    private let initialIndex = 1
    var confirmedSelectedIndex: Int
    private var selectedIndex: Int

    private let values: [Float] = [5, 10, 20, 50, 100, 250]
    private let _observers = NSHashTable.weakObjectsHashTable()
    private var observers: [RadiusDataSourceObserver] {
        return _observers.allObjects.flatMap { $0 as? RadiusDataSourceObserver }
    }

    override init() {
        confirmedSelectedIndex = initialIndex
        selectedIndex = initialIndex

        super.init()
    }

    func resetToDefaultSearchRadius() {
        selectedIndex = initialIndex
        confirmSelection()
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
