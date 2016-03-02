import Quick
import Nimble

@testable import Connect

class NewsFeedArticlePresenterSpec: QuickSpec {
    override func spec() {
        describe("NewsFeedArticlePresenter") {
            var subject: NewsFeedArticlePresenter!
            var imageService: FakeImageService!
            var timeIntervalFormatter: FakeTimeIntervalFormatter!
            let theme = NewsFeedArticlePresenterFakeTheme()

            beforeEach {
                imageService = FakeImageService()
                timeIntervalFormatter = FakeTimeIntervalFormatter()

                subject = NewsFeedArticlePresenter(
                    timeIntervalFormatter: timeIntervalFormatter,
                    imageService: imageService,
                    theme: theme)
            }

            describe("presenting a news article") {
                let newsArticleDate = NSDate(timeIntervalSince1970: 0)
                let newsArticle = NewsArticle(title: "Bernie to release new album", date: newsArticleDate, body: "yeahhh", excerpt: "excerpt A", imageURL: NSURL(string: "http://bs.com")!, url: NSURL())
                let tableView = AlwaysReusingTableView()
                let indexPath = NSIndexPath(forRow: 1, inSection: 1)

                beforeEach {
                    subject.setupTableView(tableView)
                }

                it("sets the title label using the provided news article") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    expect(cell.titleLabel.text).to(equal("Bernie to release new album"))
                }

                context("when the news article was published today") {
                    it("sets the excerpt label using the provided news article, including the abbreviated date") {
                        timeIntervalFormatter.returnsDaysSinceDate = 0
                        let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell.excerptLabel.attributedText!.string).to(equal("Now | excerpt A"))
                    }
                }

                context("when the news article was published in the past") {
                    it("sets the excerpt label using the provided news article") {
                        timeIntervalFormatter.returnsDaysSinceDate = 1
                        let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell.excerptLabel.text).to(equal("excerpt A"))
                    }
                }

                context("when the news item has an image URL") {
                    context("when the cell is tagged with the hash value of the image URL") {
                        it("does not nil out the image") {
                            var cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                            cell.tag = newsArticle.imageURL!.hashValue

                            cell.newsImageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                            cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(cell.newsImageView.image).toNot(beNil())
                        }

                        it("asks the image repository to fetch the image") {
                            subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(imageService.lastReceivedURL).to(beIdenticalTo(newsArticle.imageURL))
                        }

                        it("tags the cell with the hash of the image url") {
                            let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(cell.tag) == newsArticle.imageURL!.hashValue
                        }

                        it("marks the image visible flag as true") {
                            var cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                            cell.newsImageVisible = false
                            cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(cell.newsImageVisible).to(beTrue())
                        }

                        context("when the image is loaded succesfully") {
                            context("and the tag has not changed") {
                                it("sets the image") {
                                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.newsImageView.image).to(beIdenticalTo(bernieImage))
                                }
                            }

                            context("and the tag has changed") {
                                it("does not change the image") {
                                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                                    let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                                    cell.newsImageView.image = tonyImage
                                    cell.tag = 666

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.newsImageView.image!) === tonyImage
                                }
                            }
                        }
                    }

                    context("when the cell is not tagged with the hash value of the image URL") {
                        var cell: NewsArticleTableViewCell!

                        beforeEach {
                            cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                            cell.tag = 666
                        }

                        it("initially nils out the image") {
                            cell.newsImageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                            cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                            expect(cell.newsImageView.image).to(beNil())
                        }

                        it("asks the image repository to fetch the image") {
                            subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(imageService.lastReceivedURL).to(beIdenticalTo(newsArticle.imageURL))
                        }

                        it("shows the image view") {
                            var cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                            cell.newsImageVisible = false
                            cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(cell.newsImageVisible).to(beTrue())
                        }

                        it("tags the cell with the hash of the image url") {
                            let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            expect(cell.tag) == newsArticle.imageURL!.hashValue
                        }

                        context("when the image is loaded succesfully") {
                            context("and the tag has not changed") {
                                it("sets the image") {
                                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.newsImageView.image).to(beIdenticalTo(bernieImage))
                                }
                            }

                            context("and the tag has changed") {
                                it("does not change the image") {
                                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                                    let tonyImage = TestUtils.testImageNamed("tonybenn", type: "jpg")
                                    cell.newsImageView.image = tonyImage
                                    cell.tag = 666

                                    let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                                    imageService.lastRequestPromise.resolve(bernieImage)

                                    expect(cell.newsImageView.image!) === tonyImage
                                }
                            }
                        }
                    }
                }

                context("when the news item does not have an image URL") {
                    let newsArticle = NewsArticle(title: "Bernie to release new album", date: newsArticleDate, body: "yeahhh", excerpt: "excerpt A", imageURL: nil, url: NSURL())

                    it("nils out the image") {
                        var cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        cell.newsImageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                        cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell.newsImageView.image).to(beNil())
                    }

                    it("does not make a call to the image repository") {
                        imageService.lastReceivedURL = nil
                        subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(imageService.lastReceivedURL).to(beNil())
                    }

                    it("marks the cell as not to display the image") {
                        let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell.newsImageVisible).to(beFalse())
                    }
                }

                it("styles the cell using the theme") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.excerptLabel.font).to(equal(UIFont.boldSystemFontOfSize(21)))
                }
            }
        }
    }
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
