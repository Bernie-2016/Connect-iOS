import Quick
import Nimble

@testable import Movement

private class NewsFeedTableViewCellPresenterFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }

    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

private class DodgyNewsItem: NewsFeedItem {
    let title = "fake"
    let date = NSDate()
    let url = NSURL()
}

class ConcreteNewsFeedTableViewCellPresenterSpec: QuickSpec {
    var subject: ConcreteNewsFeedTableViewCellPresenter!
    var articlePresenter: FakeNewsFeedTableViewCellPresenter!
    private let theme = NewsFeedTableViewCellPresenterFakeTheme()

    override func spec() {
        describe("ConcreteNewsFeedTableViewCellPresenter") {
            beforeEach {
                self.articlePresenter = FakeNewsFeedTableViewCellPresenter()

                self.subject = ConcreteNewsFeedTableViewCellPresenter(articlePresenter: self.articlePresenter, theme: self.theme)
            }

            describe("presenting an error") {
                let tableView = UITableView()

                beforeEach {
                    tableView.registerClass(NewsArticleTableViewCell.self, forCellReuseIdentifier: "errorCell") // TODO: constantize this
                }

                it("has the correct text") {
                    let cell = self.subject.errorCellForTableView(tableView)

                    expect(cell.textLabel!.text).to(equal("Oops! Sorry, we couldn't load any news."))
                }

                it("styles the items in the table using the theme") {
                    let cell = self.subject.errorCellForTableView(tableView)

                    expect(cell.textLabel!.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.textLabel!.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                }
            }

            describe("presenting a news feed item") {
                let tableView = UITableView()

                context("and that item is a news article") {
                    let newsArticle = TestUtils.newsArticle()


                    beforeEach {
                        tableView.registerClass(NewsArticleTableViewCell.self, forCellReuseIdentifier: "regularCell") // TODO: constantize this
                    }

                    it("uses the article presenter") {
                        let cell = self.subject.cellForTableView(tableView, newsFeedItem: newsArticle) as! NewsArticleTableViewCell
                        expect(cell).to(beIdenticalTo(self.articlePresenter.returnedCells.last))
                        expect(self.articlePresenter.receivedTableViews.last).to(beIdenticalTo(tableView))
                        expect(self.articlePresenter.receivedNewsFeedItems.last as? NewsArticle).to(beIdenticalTo(newsArticle))
                    }
                }
            }
        }
    }
}
