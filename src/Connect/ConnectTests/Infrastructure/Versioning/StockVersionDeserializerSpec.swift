import Quick
import Nimble

@testable import Connect

class StockVersionDeserializerSpec: QuickSpec {
    override func spec() {
        describe("StockVersionDeserializer") {
            var subject: VersionDeserializer!

            beforeEach {
                subject = StockVersionDeserializer()
            }

            describe("deserializing a version") {
                var jsonDictionary: [String: AnyObject]!

                beforeEach {
                    let data = TestUtils.dataFromFixtureFileNamed("version", type: "json")

                    jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! [String : AnyObject]
                }

                it("deserializes a valid action alert correctly") {
                    let Version = try! subject.deserializeVersion(jsonDictionary)

                    expect(Version.minimumVersion) == 130
                    expect(Version.updateURL) == NSURL(string: "https://geo.itunes.apple.com/us/app/movement-bernie-2016-edition/id1047784111?mt=8")!
                }

                it("throws a missing attribute error when version is missing") {
                    jsonDictionary.removeValueForKey("minimum_version")

                    expect { try subject.deserializeVersion(jsonDictionary) }.to(throwError(VersionDeserializerError.MissingAttribute("minimum_version")))
                }

                it("throws a missing attribute error when update URL is missing") {
                    jsonDictionary.removeValueForKey("update_url")

                    expect { try subject.deserializeVersion(jsonDictionary) }.to(throwError(VersionDeserializerError.MissingAttribute("update_url")))
                }

                it("throws an invalid value error when the version is not a number") {
                    jsonDictionary["minimum_version"] = "bananas"

                    expect { try subject.deserializeVersion(jsonDictionary) }.to(throwError(VersionDeserializerError.MissingAttribute("minimum_version")))
                }

                it("throws an invalid value error when the update URL is not a valid URL") {
                    jsonDictionary["update_url"] = 666

                    expect { try subject.deserializeVersion(jsonDictionary) }.to(throwError(VersionDeserializerError.MissingAttribute("update_url")))
                }
            }
        }
    }
}
