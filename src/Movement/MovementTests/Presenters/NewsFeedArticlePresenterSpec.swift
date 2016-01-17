import Quick
import Nimble

@testable import Movement

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
                let tableView = UITableView()
                let indexPath = NSIndexPath(forRow: 1, inSection: 1)

                beforeEach {
                    subject.setupTableView(tableView)
                }

                it("sets the title label using the provided news article") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    expect(cell.titleLabel.text).to(equal("Bernie to release new album"))
                }

                it("sets the excerpt label using the provided news article") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    expect(cell.excerptLabel.text).to(equal("excerpt A"))
                }

                it("uses the time interval formatter for the date label") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    expect(cell.dateLabel.text).to(equal("abbreviated 1970-01-01 00:00:00 +0000"))
                    expect(timeIntervalFormatter.lastAbbreviatedDates).to(equal([newsArticleDate]))
                }

                it("initially nils out the image") {
                    var cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    cell.newsImageView.image = TestUtils.testImageNamed("bernie", type: "jpg")
                    cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                    expect(cell.newsImageView.image).to(beNil())
                }

                context("when the news item has an image URL") {
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

                    context("when the image is loaded succesfully") {
                        it("sets the image") {
                            let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                            let bernieImage = TestUtils.testImageNamed("bernie", type: "jpg")
                            imageService.lastRequestPromise.resolve(bernieImage)

                            expect(cell.newsImageView.image).to(beIdenticalTo(bernieImage))
                        }
                    }
                }

                context("when the news item does not have an image URL") {
                    let newsArticle = NewsArticle(title: "Bernie to release new album", date: newsArticleDate, body: "yeahhh", excerpt: "excerpt A", imageURL: nil, url: NSURL())

                    it("does not make a call to the image repository") {
                        imageService.lastReceivedURL = nil
                        subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(imageService.lastReceivedURL).to(beNil())
                    }

                    it("hides the image view") {
                        let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell.newsImageVisible).to(beFalse())
                    }
                }

                it("styles the cell using the theme") {
                    let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell

                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.excerptLabel.textColor).to(equal(UIColor.redColor()))
                    expect(cell.excerptLabel.font).to(equal(UIFont.boldSystemFontOfSize(21)))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.whiteColor()))
                }
            }
        }
    }
}
