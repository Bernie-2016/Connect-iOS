import berniesanders
import Quick
import Nimble
import UIKit

class NewsFakeTheme : FakeTheme {
    override func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    override func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    override func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }
    
    override func newsFeedDateColor() -> UIColor {
        return UIColor.brownColor()
    }
}

class FakeNewsRepository : berniesanders.NewsRepository {
    var lastCompletionBlock: ((Array<NewsItem>) -> Void)?
    var lastErrorBlock: ((NSError) -> Void)?
    var fetchNewsCalled: Bool = false
    
    init() {
    }

    func fetchNews(completion: (Array<NewsItem>) -> Void, error: (NSError) -> Void) {
        self.fetchNewsCalled = true
        self.lastCompletionBlock = completion
        self.lastErrorBlock = error
    }
}

class NewsTableViewControllerSpecs: QuickSpec {
    var subject: NewsTableViewController!
    var newsRepository: FakeNewsRepository! =  FakeNewsRepository()
    var theme: Theme! = NewsFakeTheme()
    
    override func spec() {
        beforeEach {
            let theme = NewsFakeTheme()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            self.subject = NewsTableViewController(
                theme: theme,
                newsRepository: self.newsRepository,
                dateFormatter: dateFormatter
            )
        }
        
        it("has the correct tab bar title") {
            expect(self.subject.title).to(equal("News"))
        }
        
        it("has the correct navigation item title") {
            expect(self.subject.navigationItem.title).to(equal("HOME"))
        }
                
        describe("when the controller appears") {
            beforeEach {
                self.subject.view.layoutIfNeeded()
                self.subject.viewWillAppear(false)
            }
            
            it("has an empty table") {
                expect(self.subject.tableView.numberOfSections()).to(equal(1))
                expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(0))
            }
            
            it("asks the news repository for some news") {
                expect(self.newsRepository.fetchNewsCalled).to(beTrue())
            }
            
            describe("when the news repository returns some news items", {
                var newsItemADate = NSDate(timeIntervalSince1970: 0)
                var newsItemBDate = NSDate(timeIntervalSince1970: 86401)
                
                beforeEach {
                    var newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate)
                    var newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate)

                    var newsItems = [newsItemA, newsItemB]
                    self.newsRepository.lastCompletionBlock!(newsItems)
                }
                
                it("shows the items in the table with upcased text") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellA.titleLabel.text).to(equal("BERNIE TO RELEASE NEW ALBUM"))
                    expect(cellA.dateLabel.text).to(equal("12/31/69"))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellB.titleLabel.text).to(equal("BERNIE UP IN THE POLLS!"))
                    expect(cellB.dateLabel.text).to(equal("1/1/70"))
                }
                
                it("styles the items in the table") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))

                    var cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    
                    expect(cell.titleLabel.textColor).to(equal(UIColor.magentaColor()))
                    expect(cell.titleLabel.font).to(equal(UIFont.boldSystemFontOfSize(20)))
                    expect(cell.dateLabel.textColor).to(equal(UIColor.brownColor()))
                    expect(cell.dateLabel.font).to(equal(UIFont.italicSystemFontOfSize(13)))
                }
            })
        }
    }
}

