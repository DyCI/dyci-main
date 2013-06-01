#import "IEAppDelegate.h"
#import "objc/runtime.h"

#if CEDAR_KNOWS_SOMETHING_ABOUT_FAILING_ON_IOS6_SIMULATOR
@implementation UIWindow (Private)

- (void)_createContext {
    
}

@end

@implementation UIFont (Private)

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont new];
}

- (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont new];
}

+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont new];
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    return [UIFont new];
}

+ (UIFont *)fontWithSize:(CGFloat)fontSize {
    return [UIFont new];
}

@end


@interface BKSAccelerometerFix : NSObject

@end

@implementation BKSAccelerometerFix

- (id)init {
    return nil;
}

@end

#endif


void Swizzle(Class c,  SEL orig,Class anotherClass, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(anotherClass, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSLog(@"Running Storyboard Injection Example!");
        
#if CEDAR_KNOWS_SOMETHING_ABOUT_FAILING_ON_IOS6_SIMULATOR
        NSLog(@"CEDAR_KNOWS_SOMETHING_ABOUT_FAILING_ON_IOS6_SIMULATOR!");
        CFMessagePortCreateLocal(NULL, (CFStringRef) @"PurpleWorkspacePort", NULL, NULL,NULL);
        Class clz = NSClassFromString(@"BKSAccelerometer");
        Class clz2 = NSClassFromString(@"BKSAccelerometerFix");
        Swizzle(clz, @selector(init), clz2, @selector(init));

#endif
        
        
        return UIApplicationMain(argc, argv, nil, @"IEAppDelegate");
        
    }
}