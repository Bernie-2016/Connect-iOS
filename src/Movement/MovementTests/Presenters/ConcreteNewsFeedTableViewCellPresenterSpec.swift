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
    var videoPresenter: FakeNewsFeedTableViewCellPresenter!

    override func spec() {
        describe("ConcreteNewsFeedTableViewCellPresenter") {
            beforeEach {
                self.articlePresenter = FakeNewsFeedTableViewCellPresenter()
                self.videoPresenter = FakeNewsFeedTableViewCellPresenter()
                self.subject = ConcreteNewsFeedTableViewCellPresenter(articlePresenter: self.articlePresenter, videoPresenter: self.videoPresenter)
            }

            describe("setting up a table view") {
                let tableView = UITableView()

                it("tells the article presenter to setup the table view") {
                    self.subject.setupTableView(tableView)

                    expect(self.articlePresenter.lastSetupTableView).to(beIdenticalTo(tableView))
                }

                it("tells the video presenter to setup the table view") {
                    self.subject.setupTableView(tableView)

                    expect(self.videoPresenter.lastSetupTableView).to(beIdenticalTo(tableView))
                }
            }

            describe("presenting a news feed item") {
                let tableView = UITableView()

                context("and that item is a news article") {
                    let newsArticle = TestUtils.newsArticle()

                    beforeEach {
                        self.subject.setupTableView(tableView)
                    }

                    it("uses the article presenter") {
                        let cell = self.subject.cellForTableView(tableView, newsFeedItem: newsArticle) as! NewsArticleTableViewCell
                        expect(cell).to(beIdenticalTo(self.articlePresenter.returnedCells.last))
                        expect(self.articlePresenter.receivedTableViews.last).to(beIdenticalTo(tableView))
                        expect(self.articlePresenter.receivedNewsFeedItems.last as? NewsArticle).to(beIdenticalTo(newsArticle))
                    }
                }

                describe("and that item is a video") {
                    let video = TestUtils.video()

                    beforeEach {
                        self.subject.setupTableView(tableView)
                    }

                    it("uses the video presenter") {
                        let cell = self.subject.cellForTableView(tableView, newsFeedItem: video) as! NewsArticleTableViewCell
                        expect(cell).to(beIdenticalTo(self.videoPresenter.returnedCells.last))
                        expect(self.videoPresenter.receivedTableViews.last).to(beIdenticalTo(tableView))
                        expect(self.videoPresenter.receivedNewsFeedItems.last as? Video).to(beIdenticalTo(video))
                    }
                }
            }
        }
    }
}
