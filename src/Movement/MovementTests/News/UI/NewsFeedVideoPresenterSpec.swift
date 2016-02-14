import Quick
import Nimble

@testable import Movement


class NewsFeedVideoPresenterSpec: QuickSpec {
    override func spec() {
        var subject: NewsFeedVideoPresenter!
        var timeIntervalFormatter: FakeTimeIntervalFormatter!
        var urlProvider: NewsFeedVideoFakeURLProvider!
        var imageService: FakeImageService!
        let theme = NewsFeedVideoPresenterFakeTheme()

        describe("NewsFeedVideoPresenter") {
            beforeEach {
                timeIntervalFormatter = FakeTimeIntervalFormatter()
                urlProvider = NewsFeedVideoFakeURLProvider()
                imageService = FakeImageService()

                subject = NewsFeedVideoPresenter(
                    timeIntervalFormatter: timeIntervalFormatter,
                    urlProvider: urlProvider,
                    imageService: imageService,
                    theme: theme
                )
            }

            describe("presenting a video") {
                let videoDate = NSDate(timeIntervalSince1970: 0)
                let video = Video(title: "Some video", date: videoDate, identifier: "some-identifier", description: "Stuff that moves")
                let tableView = AlwaysReusingTableView()
                let indexPath = NSIndexPath(forRow: 1, inSection: 1)

                beforeEach {
                    subject.setupTableView(tableView)
                }

                it("sets the title label using the provided video") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell
                    expect(cell.titleLabel.text).to(equal("Some video"))
                }

                context("when the video was published today") {
                    it("sets the description label using the provided video, including the abbreviated date") {
                        timeIntervalFormatter.returnsDaysSinceDate = 0
                        let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell
                        expect(cell.descriptionLabel.text).to(equal("Now | Stuff that moves"))
                    }
                }

                context("when the video was published in the past") {
                    it("sets the description label using the provided video") {
                        timeIntervalFormatter.returnsDaysSinceDate = 1
                        let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell
                        expect(cell.descriptionLabel.text).to(equal("Stuff that moves"))
                    }
                }

                it("asks the image repository to fetch the URL from the provider") {
                    subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath)

                    expect(urlProvider.lastReceivedIdentifier).to(equal("some-identifier"))
                    expect(imageService.lastReceivedURL).to(beIdenticalTo(urlProvider.returnedURL))
                }

                context("when the image tag does not match the hash of the thumbnail URL") {
                    it("nils out the thumbnail image") {
                        var cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                        let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell.thumbnailImageView.image = bernieImage
                        cell.tag = 666

                        cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                        expect(cell.thumbnailImageView.image).to(beNil())
                    }
                }

                context("when the image tag hasn't changed") {
                    it("leaves the thumbnail image alone") {
                        var cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                        let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell.thumbnailImageView.image = bernieImage

                        cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                        expect(cell.thumbnailImageView.image) === bernieImage
                    }
                }

                context("when the cell is for the first section and the first row") {
                    it("sets the top spacing to zero") {
                        let zerothIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                        let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: zerothIndexPath) as! NewsFeedVideoTableViewCell

                        expect(cell.topSpaceConstraint.constant).to(equal(0))
                    }
                }

                context("when the cell is not for the first section and first row") {
                    it("sets the top spacing to something greater than zero") {
                        var nonZeroIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                        var cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: nonZeroIndexPath) as! NewsFeedVideoTableViewCell

                        expect(cell.topSpaceConstraint.constant).to(beGreaterThan(0))

                        nonZeroIndexPath = NSIndexPath(forRow: 0, inSection: 1)
                        cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: nonZeroIndexPath) as! NewsFeedVideoTableViewCell

                        expect(cell.topSpaceConstraint.constant).to(beGreaterThan(0))

                    }
                }

                context("when the image is loaded succesfully") {
                    context("when the cell tag hasn't changed") {
                        it("sets the image") {
                            let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                            let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")

                            imageService.lastRequestPromise.resolve(bernieImage)

                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                expect(cell.thumbnailImageView.image).to(beIdenticalTo(bernieImage))
                            })
                        }
                    }

                    context("when the cell tag has changed") {
                        it("leaves the image alone") {
                            let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                            let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                            cell.tag = 42
                            cell.thumbnailImageView.image = tonyImage

                            let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            imageService.lastRequestPromise.resolve(bernieImage)

                            expect(cell.thumbnailImageView.image) === tonyImage
                        }
                    }
                }

                it("styles the cell using the theme") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsFeedVideoTableViewCell

                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.descriptionLabel.font).to(equal(UIFont.boldSystemFontOfSize(21)))
                    expect(cell.overlayView.backgroundColor).to(equal(UIColor.orangeColor()))
                }
            }
        }
    }
}

private class NewsFeedVideoFakeURLProvider: FakeURLProvider {
    var lastReceivedIdentifier: String!
    let returnedURL = NSURL(string: "https://example.com/youtube")!

    override func youtubeThumbnailURL(identifier: String) -> NSURL {
        lastReceivedIdentifier = identifier
        return returnedURL
    }
}

private class NewsFeedVideoPresenterFakeTheme: FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }

    override func defaultDisclosureColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func highlightDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func newsFeedExcerptFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(21)
    }

    override func newsFeedExcerptColor() -> UIColor {
        return UIColor.redColor()
    }

    override func newsFeedVideoOverlayBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
}
