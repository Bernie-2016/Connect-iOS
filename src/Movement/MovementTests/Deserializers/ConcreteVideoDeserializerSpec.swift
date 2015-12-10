import Foundation
import Quick
import Nimble
@testable import Movement

class ConcreteVideDeserializerSpec : QuickSpec {
    var subject: ConcreteVideoDeserializer!

    override func spec() {
        describe("ConcreteVideoDeserializer") {
            beforeEach {
                self.subject = ConcreteVideoDeserializer()
            }

            it("deserializes the videos correctly") {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyyz"

                let data = TestUtils.dataFromFixtureFileNamed("videos", type: "json")

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                var videos = self.subject.deserializeVideos(jsonDictionary)

                expect(videos.count).to(equal(2))
                let videoA = videos[0]
                expect(videoA.title).to(equal("Butterfield Diet Plan"))
                var expectedDate = dateFormatter.dateFromString("05-10-2015Z")
                expect(videoA.date).to(equal(expectedDate))
                expect(videoA.description).to(equal("The results have been incredible"))
                expect(videoA.identifier).to(equal("wtF3_ybJJ50"))

                let videoB = videos[1]
                expect(videoB.title).to(equal("Butterfield Sports Restuarant"))
                expectedDate = dateFormatter.dateFromString("25-10-2015Z")
                expect(videoB.date).to(equal(expectedDate))
                expect(videoB.description).to(equal("Dine Like a True Champion"))
                expect(videoB.identifier).to(equal("asxxHrKt9EQ"))
            }

            context("when title, date, description or videoId are missing") {
                it("should not explode and ignore videos that lack them") {
                    let data = TestUtils.dataFromFixtureFileNamed("video_nasties", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                    let videos = self.subject.deserializeVideos(jsonDictionary)

                    expect(videos.count).to(equal(1))
                    let video = videos[0]
                    expect(video.title).to(equal("The Brian Butterfield Ultra-Pill"))
                }
            }

            context("when there's not enough hits") {
                it("should not explode") {
                    var videos = self.subject.deserializeVideos([String: AnyObject]())
                    expect(videos.count).to(equal(0))

                    videos = self.subject.deserializeVideos(["hits": [String: AnyObject]()])
                    expect(videos.count).to(equal(0))

                    videos = self.subject.deserializeVideos(["hits": [ "hits": [String: AnyObject]()]])
                    expect(videos.count).to(equal(0));
                }
            }
        }
    }
}
