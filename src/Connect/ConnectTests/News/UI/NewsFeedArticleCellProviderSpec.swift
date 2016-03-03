import Quick
import Nimble

@testable import Connect

class NewsFeedArticleCellProviderSpec: QuickSpec {
    override func spec() {
        describe("NewsFeedArticleCellProvider") {
            var subject: NewsFeedArticleCellProvider!
            var imageService: FakeImageService!
            var timeIntervalFormatter: FakeTimeIntervalFormatter!
            let theme = NewsFeedArticlePresenterFakeTheme()

            var collectionView: UICollectionView!
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            var dataSource: UICollectionViewDataSource!
            beforeEach {
                imageService = FakeImageService()
                timeIntervalFormatter = FakeTimeIntervalFormatter()

                subject = NewsFeedArticleCellProvider(
                    imageService: imageService,
                    timeIntervalFormatter: timeIntervalFormatter,
                    theme: theme
                )

                collectionView = AlwaysReusingCollectionView(
                    frame: CGRect.zero,
                    collectionViewLayout: UICollectionViewFlowLayout()
                )

                dataSource = FakeDataSource()
                collectionView.dataSource = dataSource
            }

            describe("presenting a news article") {
                let newsArticle = NewsArticle(title: "Bernie to release new album", date: NSDate(), body: "yeahhh", excerpt: "yea", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())

                beforeEach {
                    subject.setupCollectionView(collectionView)
                }

                it("sets the title label using the provided news article") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.titleLabel.text) == "Bernie to release new album"
                }

                it("sets the excerpt label using the provided news article") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.excerptLabel.text) == "yea"
                }


                it("sets the date label using the time interval formatter") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(timeIntervalFormatter.lastFormattedDate) === newsArticle.date

                    expect(cell.dateLabel.text) == "human date"
                }

                it("styles the cell using the theme") {
                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                    expect(cell.backgroundColor) == UIColor.redColor()
                    expect(cell.titleLabel.textColor) == UIColor.magentaColor()
                    expect(cell.titleLabel.font) == UIFont.boldSystemFontOfSize(20)
                    expect(cell.excerptLabel.font) == UIFont.boldSystemFontOfSize(21)
                    expect(cell.dateLabel.font) == UIFont.italicSystemFontOfSize(13)
                    expect(cell.dateLabel.textColor) == UIColor.purpleColor()
                    expect(UIColor(CGColor: cell.layer.shadowColor!)) == UIColor.yellowColor()
                }

                context("when the news article has an image URL") {
                    context("when the cell is tagged with the hash value of the image URL") {
                        it("does not nil out the image") {
                            var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)  as! NewsArticleCollectionViewCell
                            cell.tag = newsArticle.imageURL!.hashValue

                            cell.imageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                            cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)  as! NewsArticleCollectionViewCell

                            expect(cell.imageView.image).toNot(beNil())
                        }

                        it("asks the image repository to fetch the image") {
                            subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)
                            expect(imageService.lastReceivedURL) === newsArticle.imageURL
                        }

                        it("tags the cell with the hash of the image URL") {
                            let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)!

                            expect(cell.tag) == newsArticle.imageURL!.hashValue
                        }

                        it("marks the image visible flag as true") {
                            var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                            cell.imageVisible = false

                            cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                            expect(cell.imageVisible) == true
                        }

                        context("when the image is loaded successfully") {
                            context("and the tag has not changed") {
                                it("sets the image") {
                                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.imageView.image) === bernieImage
                                }
                            }

                            context("and the tag has changed") {
                                it("does not change the image") {
                                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                                    let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                                    cell.imageView.image = tonyImage
                                    cell.tag = 666

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.imageView.image!) === tonyImage
                                }
                            }
                        }
                    }

                    context("when the cell is not tagged with the hash value of the image URL") {
                        it("initially nils out the image") {
                            var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)  as! NewsArticleCollectionViewCell
                            cell.tag = 666

                            cell.imageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                            cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)  as! NewsArticleCollectionViewCell

                            expect(cell.imageView.image).to(beNil())
                        }

                        it("asks the image repository to fetch the image") {
                            subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)
                            expect(imageService.lastReceivedURL) === newsArticle.imageURL
                        }

                        it("tags the cell with the hash of the image URL") {
                            let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath)!

                            expect(cell.tag) == newsArticle.imageURL!.hashValue
                        }

                        it("marks the image visible flag as true") {
                            var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                            cell.imageVisible = false

                            cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                            expect(cell.imageVisible) == true
                        }

                        context("when the image is loaded successfully") {
                            context("and the tag has not changed") {
                                it("sets the image") {
                                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.imageView.image) === bernieImage
                                }
                            }

                            context("and the tag has changed") {
                                it("does not change the image") {
                                    let cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                                    let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                                    cell.imageView.image = tonyImage
                                    cell.tag = 666

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.imageView.image!) === tonyImage
                                }
                            }
                        }
                    }
                }

                context("when the news article does not have an image URL") {
                    let newsArticle = TestUtils.newsArticleWithoutImage()

                    it("nils out the image") {
                        var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        cell.imageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        expect(cell.imageView.image).to(beNil())
                    }

                    it("sets the tag to zero") {
                        var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        cell.tag = 666
                        cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell

                        expect(cell.tag) == 0
                    }

                    it("does not make a call to the image repository") {
                        imageService.lastReceivedURL = nil
                        subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        expect(imageService.lastReceivedURL).to(beNil())
                    }

                    it("marks the cell as not to display the image") {
                        var cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        cell.imageVisible = true

                        cell = subject.cellForCollectionView(collectionView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleCollectionViewCell
                        expect(cell.imageVisible) == false
                    }
                }
            }

            describe("presenting a non-news article") {
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
        return UIFont.italicSystemFontOfSize(13)
    }

    private override func newsFeedDateColor() -> UIColor {
        return UIColor.purpleColor()
    }

    private override func contentBackgroundColor() -> UIColor {
        return UIColor.redColor()
    }

    private override func newsFeedCellBorderColor() -> UIColor {
        return UIColor.yellowColor()
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
