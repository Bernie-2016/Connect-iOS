import Quick
import Nimble

@testable import Connect

class ActionAlertSpec: QuickSpec {
    override func spec() {
        describe("ActionAlert") {
            var subject: ActionAlert!

            describe(".isFacebookVideo") {
                context("when the action alert is a facebook video") {
                    it("returns true") {
                        subject = ActionAlert(
                            identifier: "fake-id",
                            title: "title",
                            body: "<div class='fb-video'></div>",
                            shortDescription: "",
                            date: "",
                            targetURL: nil,
                            twitterURL: nil,
                            tweetID: nil
                        )

                        expect(subject.isFacebookVideo()) == true
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
                            targetURL: nil,
                            twitterURL: nil,
                            tweetID: nil
                        )

                        expect(subject.isFacebookVideo()) == false
                    }
                }
            }

            describe(".isFacebookPost") {
                context("when the action alert is a facebook post") {
                    it("returns true") {
                        subject = ActionAlert(
                            identifier: "fake-id",
                            title: "title",
                            body: "<div class='fb-post'></div>",
                            shortDescription: "",
                            date: "",
                            targetURL: nil,
                            twitterURL: nil,
                            tweetID: nil
                        )

                        expect(subject.isFacebookPost()) == true
                    }
                }

                context("when the action alert is not a facebook post") {
                    it("returns nil") {
                        subject = ActionAlert(
                            identifier: "fake-id",
                            title: "title",
                            body: "<div class='fb-video'></div>",
                            shortDescription: "",
                            date: "",
                            targetURL: nil,
                            twitterURL: nil,
                            tweetID: nil
                        )

                        expect(subject.isFacebookPost()) == false
                    }
                }
            }

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
