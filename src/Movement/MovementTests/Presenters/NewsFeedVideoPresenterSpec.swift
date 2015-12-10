import Quick
import Nimble

@testable import Movement

class NewsFeedVideoPresenterSpec: QuickSpec {
    var subject: NewsFeedVideoPresenter!

    override func spec() {
        describe("NewsFeedVideoPresenter") {
            beforeEach {
                self.subject = NewsFeedVideoPresenter()
            }

            describe("presenting a video") {
                let videoDate = NSDate(timeIntervalSince1970: 0)
                let video = Video(title: "Some video", date: videoDate, identifier: "asdf", description: "Stuff that moves")
                let tableView = UITableView()

                beforeEach {
                    self.subject.setupTableView(tableView)
                }

                it("sets the title label using the provided video") {
                    let cell = self.subject.cellForTableView(tableView, newsFeedItem: video) as! NewsFeedVideoTableViewCell
                    expect(cell.titleLabel.text).to(equal("Some video"))
                }
            }
        }
    }
}
