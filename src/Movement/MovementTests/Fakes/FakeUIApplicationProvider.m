#import "FakeUIApplicationProvider.h"

@implementation FakeUIApplicationProvider

+ (UIApplication *)fakeUIApplication {
    return (UIApplication *)[NSObject new];
}

@end
