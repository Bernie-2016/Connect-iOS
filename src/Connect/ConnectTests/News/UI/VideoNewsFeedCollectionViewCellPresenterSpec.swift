import Quick
import Nimble

@testable import Connect

class VideoNewsFeedCollectionViewCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("VideoNewsFeedCollectionViewCellPresenter") {
            var subject: VideoNewsFeedCollectionViewCellPresenter!
            var urlProvider: NewsFeedVideoFakeURLProvider!
            var imageService: FakeImageService!

            var collectionView: UICollectionView!
            var dataSource: FakeDataSource!
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            beforeEach {
                imageService = FakeImageService()
                urlProvider = NewsFeedVideoFakeURLProvider()

                subject = VideoNewsFeedCollectionViewCellPresenter(
                    imageService: imageService,
                    urlProvider: urlProvider
                )

                collectionView = AlwaysReusingCollectionView(
                    frame: CGRect.zero,
                    collectionViewLayout: UICollectionViewFlowLayout()
                )

                dataSource = FakeDataSource()
                collectionView.dataSource = dataSource
            }

            describe("presenting a video") {
                let video = TestUtils.video()

                beforeEach {
                    subject.setupCollectionView(collectionView)
                }

                it("sets the title label using the provided news article") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.titleLabel.text) == "Bernie MegaMix"
                }

                it("asks the image repository to fetch the URL from the provider") {
                    subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath)

                    expect(urlProvider.lastReceivedIdentifier) == video.identifier
                    expect(imageService.lastReceivedURL) === urlProvider.returnedURL
                }

                it("marks the image as visible") {
                    var cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    cell.imageVisible = false

                    cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.imageVisible) == true
                }

                context("when the image tag does not match the hash of the thumbnail URL") {
                    it("nils out the thumbnail image") {
                        var cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                        let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell.imageView.image = bernieImage
                        cell.tag = 666

                        cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                        expect(cell.imageView.image).to(beNil())
                    }
                }

                context("when the image tag hasn't changed") {
                    it("leaves the image alone") {
                        var cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                        let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell.imageView.image = bernieImage

                        cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                        expect(cell.imageView.image) === bernieImage
                    }
                }

                context("when the image is loaded succesfully") {
                    context("when the cell tag hasn't changed") {
                        it("sets the image") {
                            let cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                            let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")

                            imageService.lastRequestPromise.resolve(bernieImage)

                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                expect(cell.imageView.image) === bernieImage
                            })
                        }
                    }

                    context("when the cell tag has changed") {
                        it("leaves the image alone") {
                            let cell = subject.cellForCollectionView(collectionView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleCollectionViewCell

                            let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                            cell.tag = 42
                            cell.imageView.image = tonyImage

                            let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            imageService.lastRequestPromise.resolve(bernieImage)

                            expect(cell.imageView.image) === tonyImage
                        }
                    }
                }
            }

            describe("presenting a non-video article") {
                beforeEach {
                    subject.setupCollectionView(collectionView)
                }

                it("returns nil") {
                    let otherNewsFeedItem = FakeNewsFeedItem()

                    expect(subject.cellForCollectionView(collectionView, newsFeedItem: otherNewsFeedItem, indexPath: indexPath)).to(beNil())
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

private class FakeNewsFeedItem: NewsFeedItem {
    var title = ""
    var date = NSDate()
    var identifier = ""
}

private class NewsFeedArticlePresenterFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }

    override func newsFeedExcerptFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(21)
    }

    override func newsFeedExcerptColor() -> UIColor {
        return UIColor.redColor()
    }

    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }

    override func defaultDisclosureColor() -> UIColor {
        return UIColor.brownColor()
    }

    override func highlightDisclosureColor() -> UIColor {
        return UIColor.whiteColor()
    }
}

private class FakeDataSource: NSObject, UICollectionViewDataSource {
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
