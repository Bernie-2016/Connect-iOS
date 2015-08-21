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


class NewsTableViewControllerSpecs: QuickSpec {
    var subject: NewsTableViewController!
    var newsRepository: FakeNewsRepository! =  FakeNewsRepository()
    
    override func spec() {
        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.subject = storyboard.instantiateViewControllerWithIdentifier("NewsTableViewController") as! NewsTableViewController
            self.subject.newsRepository = self.newsRepository
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
                
                it("shows the items in the table") {
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                    
                    var cellA = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellA.titleLabel.text).to(equal("Bernie to release new album"))
                    expect(cellA.dateLabel.text).to(equal(newsItemADate.description))
                    
                    var cellB = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TitleSubTitleTableViewCell
                    expect(cellB.titleLabel.text).to(equal("Bernie up in the polls!"))
                    expect(cellB.dateLabel.text).to(equal(newsItemBDate.description))
                }
            })
        }
    }
}

