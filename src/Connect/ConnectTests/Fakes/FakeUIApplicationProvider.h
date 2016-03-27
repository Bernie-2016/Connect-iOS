@import UIKit;

@interface FakeUIApplication : NSObject

@property (nonatomic) UIWindow *keyWindow;

@end


@interface FakeUIApplicationProvider : NSObject

+ (UIApplication *)fakeUIApplication;

@end
