import berniesanders
import Quick
import Nimble
import UIKit

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

class FakeTheme : berniesanders.Theme {
    func newsFeedTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(20)
    }
    
    func newsFeedTitleColor() -> UIColor {
        return UIColor.magentaColor()
    }
    
    func newsFeedDateFont() -> UIFont {
        return UIFont.italicSystemFontOfSize(13)    }
    
    func newsFeedDateColor() -> UIColor {
        return UIColor.brownColor()
    }
}


class NewsTableViewControllerSpecs: QuickSpec {
    var subject: NewsTableViewController!
    var newsRepository: FakeNewsRepository! =  FakeNewsRepository()
    var theme: Theme! = FakeTheme()
    
    override func spec() {
        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.subject = storyboard.instantiateViewControllerWithIdentifier("NewsTableViewController") as! NewsTableViewController
            self.subject.newsRepository = self.newsRepository
            self.subject.theme = self.theme
            self.subject.beginAppearanceTransition(true, animated: false)
            self.subject.endAppearanceTransition()
        }
        
        describe("when the controller appears") {
            beforeEach {
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
                var newsItemADate = NSDate()
                var newsItemBDate = NSDate()
                
                beforeEach {
                    var newsItemA = NewsItem(title: "Bernie to release new album", date: newsItemADate)
                    var newsItemB = NewsItem(title: "Bernie up in the polls!", date: newsItemBDate)

                    var newsItems = [newsItemA, newsItemB]
                    print(self.newsRepository.lastCompletionBlock)
                    self.newsRepository.lastCompletionBlock!(newsItems)
                }
                
                it("shows the items in the table with upcased text") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellA.titleLabel.text).to(equal("BERNIE TO RELEASE NEW ALBUM"))
                    expect(cellA.dateLabel.text).to(equal(newsItemADate.description))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellB.titleLabel.text).to(equal("BERNIE UP IN THE POLLS!"))
                    expect(cellB.dateLabel.text).to(equal(newsItemBDate.description))
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

