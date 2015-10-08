import Foundation
import Quick
import Nimble
import berniesanders


class ConcreteApplicationSettingsRepositorySpec: QuickSpec {
    var subject: ConcreteApplicationSettingsRepository!
    var userDefaults: NSUserDefaults!
    
    override func spec() {
        describe("ConcreteApplicationSettingsRepository") {
            beforeEach {
                self.userDefaults = NSUserDefaults()
                
                self.subject = ConcreteApplicationSettingsRepository(userDefaults: self.userDefaults)
            }
            
            afterEach {
                for key in self.userDefaults.dictionaryRepresentation().keys {
                    self.userDefaults.removeObjectForKey(key as! String)
                }
            }
            
            describe("asking if the user has agreed to terms") {
                context("when the user has not agreed to terms") {
                    it("immediately calls the completion handler with false") {
                        var hasAgreedToTerms = true
                        self.subject.termsAndConditionsAgreed({ (receivedHasAgreedToTerms) -> Void in
                            hasAgreedToTerms = receivedHasAgreedToTerms
                        })
                        
                        expect(hasAgreedToTerms).to(beFalse())
                    }
                }
                
                context("when the user has agreed to terms") {
                    it("immediately calls the completion handler with true") {
                        var hasAgreedToTerms = false

                        self.subject.userAgreedToTerms({ () -> Void in
                                self.subject.termsAndConditionsAgreed({ (receivedHasAgreedToTerms) -> Void in
                                    hasAgreedToTerms = receivedHasAgreedToTerms
                                })
                        })
                        
                        expect(hasAgreedToTerms).to(beTrue())
                    }
                }
            }
        }
    }
}
