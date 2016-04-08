import Quick
import Nimble

@testable import Connect

class ActionAlertSpec: QuickSpec {
    override func spec() {
        describe("ActionAlert") {
            var subject: ActionAlert!

            describe(".shareURL") {
                context("when the action alert is a facebook video") {
                    context("and has a target URL") {
                        it("returns the target URL") {
                            let expectedURL = NSURL(string: "https://example.com")!
                            subject = ActionAlert(
                                identifier: "fake-id",
                                title: "title",
                                body: "<div class='fb-video'></div>",
                                shortDescription: "",
                                date: "",
                                targetURL: expectedURL,
                                twitterURL: nil,
                                tweetID: nil
                            )

                            expect(subject.shareURL()) === expectedURL
                        }
                    }

                    context("and it does not have a target URL") {
                        it("returns nil") {
                            subject = ActionAlert(
                                identifier: "fake-id",
                                title: "title",
                                body: "<div class='fb-video'></div>",
                                shortDescription: "",
                                date: "",
                                targetURL: nil,
                                twitterURL: NSURL(string: "https://example.com")!,
                                tweetID: nil
                            )

                            expect(subject.shareURL()).to(beNil())
                        }
                    }
                }

                context("when the action alert is not a facebook video") {
                    it("returns nil") {
                        subject = ActionAlert(
                            identifier: "fake-id",
                            title: "title",
                            body: "<div class='fb-post'></div>",
                            shortDescription: "",
                            date: "",
                            targetURL: NSURL(string: "https://example.com")!,
                            twitterURL: nil,
                            tweetID: nil
                        )

                        expect(subject.shareURL()).to(beNil())
                    }
                }
            }
        }
    }
}
