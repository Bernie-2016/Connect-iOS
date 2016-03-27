#import "FakeUIApplicationProvider.h"

@implementation FakeUIApplication

@synthesize keyWindow;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.keyWindow = [UIWindow new];
    }
    
    return self;
}

@end

@implementation FakeUIApplicationProvider

+ (UIApplication *)fakeUIApplication {
    return (UIApplication *)[FakeUIApplication new];
}

@end


