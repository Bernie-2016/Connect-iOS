import Quick
import Nimble

@testable import Movement

private class DodgyNewsItem: NewsFeedItem {
    let title = "fake"
    let date = NSDate()
    let url = NSURL()
    let identifier = "this is dodgy"
}

class ConcreteNewsFeedTableViewCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("ConcreteNewsFeedTableViewCellPresenter") {
            var subject: ConcreteNewsFeedTableViewCellPresenter!
            var articlePresenter: FakeNewsFeedTableViewCellPresenter!
            var videoPresenter: FakeNewsFeedTableViewCellPresenter!

            beforeEach {
                articlePresenter = FakeNewsFeedTableViewCellPresenter()
                videoPresenter = FakeNewsFeedTableViewCellPresenter()
                subject = ConcreteNewsFeedTableViewCellPresenter(articlePresenter: articlePresenter, videoPresenter: videoPresenter)
            }

            describe("setting up a table view") {
                let tableView = UITableView()

                it("tells the article presenter to setup the table view") {
                    subject.setupTableView(tableView)

                    expect(articlePresenter.lastSetupTableView).to(beIdenticalTo(tableView))
                }

                it("tells the video presenter to setup the table view") {
                    subject.setupTableView(tableView)

                    expect(videoPresenter.lastSetupTableView).to(beIdenticalTo(tableView))
                }
            }

            describe("presenting a news feed item") {
                let tableView = UITableView()

                context("and that item is a news article") {
                    let newsArticle = TestUtils.newsArticle()

                    beforeEach {
                        subject.setupTableView(tableView)
                    }

                    it("uses the article presenter") {
                        let indexPath = NSIndexPath(forRow: 1, inSection: 1)
                        let cell = subject.cellForTableView(tableView, newsFeedItem: newsArticle, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell).to(beIdenticalTo(articlePresenter.returnedCells.last))
                        expect(articlePresenter.receivedTableViews.last).to(beIdenticalTo(tableView))
                        expect(articlePresenter.receivedNewsFeedItems.last as? NewsArticle).to(beIdenticalTo(newsArticle))
                        expect(articlePresenter.receivedIndexPaths.last).to(equal(indexPath))
                    }
                }

                describe("and that item is a video") {
                    let video = TestUtils.video()

                    beforeEach {
                        subject.setupTableView(tableView)
                    }

                    it("uses the video presenter") {
                        let indexPath = NSIndexPath(forRow: 1, inSection: 1)
                        let cell = subject.cellForTableView(tableView, newsFeedItem: video, indexPath: indexPath) as! NewsArticleTableViewCell
                        expect(cell).to(beIdenticalTo(videoPresenter.returnedCells.last))
                        expect(videoPresenter.receivedTableViews.last).to(beIdenticalTo(tableView))
                        expect(videoPresenter.receivedNewsFeedItems.last as? Video).to(beIdenticalTo(video))
                        expect(videoPresenter.receivedIndexPaths.last).to(equal(indexPath))
                    }
                }
            }
        }
    }
}
