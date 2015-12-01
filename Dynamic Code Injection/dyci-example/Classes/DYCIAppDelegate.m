//
//  DYCIAppDelegate.m
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <objc/runtime.h>
#import "DYCIAppDelegate.h"

#import "DYCIViewController.h"



@implementation DYCIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   // Uncomment this to DISABLE dyci
//    [NSClassFromString(@"SFDynamicCodeInjection") performSelector:@selector(disable)];
//    [NSClassFromString(@"SFDynamicCodeInjection") performSelector:@selector(notifyAllClassesOnInjection)];

   
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[DYCIViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
