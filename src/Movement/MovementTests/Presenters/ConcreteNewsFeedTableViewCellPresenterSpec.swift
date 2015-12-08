import Quick
import Nimble

@testable import Movement

private class DodgyNewsItem: NewsFeedItem {
    let title = "fake"
    let date = NSDate()
    let url = NSURL()
}

class ConcreteNewsFeedTableViewCellPresenterSpec: QuickSpec {
    var subject: ConcreteNewsFeedTableViewCellPresenter!
    var articlePresenter: FakeNewsFeedTableViewCellPresenter!

    override func spec() {
        describe("ConcreteNewsFeedTableViewCellPresenter") {
            beforeEach {
                self.articlePresenter = FakeNewsFeedTableViewCellPresenter()

                self.subject = ConcreteNewsFeedTableViewCellPresenter(articlePresenter: self.articlePresenter)
            }

            describe("setting up a table view") {
                it("tells the article presenter to setup the table view") {
                    let tableView = UITableView()
                    self.subject.setupTableView(tableView)

                    expect(self.articlePresenter.lastSetupTableView).to(beIdenticalTo(tableView))
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
