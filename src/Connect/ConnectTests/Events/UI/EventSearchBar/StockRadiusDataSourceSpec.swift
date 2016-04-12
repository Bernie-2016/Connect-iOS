import Quick
import Nimble

@testable import Connect

class StockRadiusDataSourceSpec: QuickSpec {
    override func spec() {
        describe("StockRadiusDataSource") {
            var subject: RadiusDataSource!

            var observerA: MockRadiusDataSourceObserver!
            var observerB: MockRadiusDataSourceObserver!
            beforeEach {
                subject = StockRadiusDataSource()

                observerA = MockRadiusDataSourceObserver()
                observerB = MockRadiusDataSourceObserver()

                subject.addObserver(observerA)
                subject.addObserver(observerB)
            }

            describe("the initial value") {
                it("should be the correct value") {
                    expect(subject.currentMilesValue) == 10.0
                }
            }

            describe("as a picker view data source") {
                it("should have one component") {
                    expect(subject.numberOfComponentsInPickerView(UIPickerView())) == 1
                }

                it("should have the correct number of rows") {
                    expect(subject.pickerView(UIPickerView(), numberOfRowsInComponent: 0)) == 6
                }

                it("should have the correct strings for each row") {
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 0, forComponent: 0)) == "5 miles"
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 1, forComponent: 0)) == "10 miles"
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 2, forComponent: 0)) == "20 miles"
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 3, forComponent: 0)) == "50 miles"
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 4, forComponent: 0)) == "100 miles"
                    expect(subject.pickerView!(UIPickerView(), titleForRow: 5, forComponent: 0)) == "250 miles"
                }
            }

            describe("confirming the selection") {
                it("notifies observers of the currently selected value") {
                    subject.confirmSelection()

                    expect(observerA.lastUpdatedRadiusMiles) == 10.0
                    expect(observerB.lastUpdatedRadiusMiles) == 10.0

                    subject.pickerView!(UIPickerView(), didSelectRow: 2, inComponent: 0)
                    subject.confirmSelection()

                    expect(observerA.lastUpdatedRadiusMiles) == 20.0
                    expect(observerB.lastUpdatedRadiusMiles) == 20.0
                }

                it("updates the current value") {
                    subject.pickerView!(UIPickerView(), didSelectRow: 2, inComponent: 0)
                    subject.confirmSelection()

                    expect(subject.currentMilesValue) == 20.0
                }
            }

            describe("resetting to the default search radius") {
                it("should be the same as the initial value") {
                    let initialValue = subject.currentMilesValue

                    subject.pickerView!(UIPickerView(), didSelectRow: 2, inComponent: 0)
                    subject.confirmSelection()

                    subject.resetToDefaultSearchRadius()

                    expect(subject.currentMilesValue) == initialValue
                }

                it("notifies observers of the selected value") {
                    subject.pickerView!(UIPickerView(), didSelectRow: 2, inComponent: 0)
                    subject.confirmSelection()

                    subject.resetToDefaultSearchRadius()

                    expect(observerA.lastUpdatedRadiusMiles) == 10.0
                    expect(observerB.lastUpdatedRadiusMiles) == 10.0
                }
            }
        }
    }
}

private class MockRadiusDataSourceObserver: RadiusDataSourceObserver {
    var lastUpdatedRadiusMiles: Float?
    func radiusDataSourceDidUpdateRadiusMiles(radiusMiles: Float) {
        lastUpdatedRadiusMiles = radiusMiles
    }
}
