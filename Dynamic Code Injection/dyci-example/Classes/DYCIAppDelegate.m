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


#import "DYCIMacro.h"

@implementation DYCIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   // Uncomment this to DISABLE dyci
   // [NSClassFromString(@"SFDynamicCodeInjection") performSelector:@selector(disable)];
   
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[DYCIViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}


/*
This example of below shows a pattern that using a handy macro(via 'DYCIMacro.h') when working revert to original frequently.
You can use this macro instead of overriding 'updateOnClassInjection'.

1. Define some code 'BEGIN_INJECTION ~ END_INJECTION', 'BEGIN_REJECTION ~  END_REJECTION'.
if line of 'code' is being exist, DYCI will call BEGIN_INJECTION block.

        BEGIN_INJECTION
            ... code ...
        END_INJECTION

        BEGIN_REJECTION
            ... revert to original state ...
        END_REJECTION

2. Simulator is still running. Change 'INJECTION' block to empty line if you want it to revert.
Then DYCI will call 'BEGIN_REJECTION ~ END_REJECTION' block. And repeat.

    BEGIN_INJECTION
    END_INJECTION
 */
BEGIN_INJECTION
    self.viewController.textLabel.text = @"Change value and then remove this line to revert.";
//    @throw [[NSException alloc] initWithName:@"some exception while running test" reason:@"Unknown but I don't wan't crash." userInfo:nil];
END_INJECTION

//pre-defined original
BEGIN_REJECTION
    self.viewController.textLabel.text = @"Hi there!\n"
        "Seems you've been able to run DYCI project!\n"
        "Congratulations\n"
        "The most hard work is already done.\n"
        "First, make sure you're installed DYCI\n"
        "There will be no magic, if you don't\n"
        "But if you do... Uncomment level #1 lines...\n"
        "And press ^X (Product|Recompile and inject) in Xcode";
END_REJECTION


- (void)applicationWillResignActive:(UIApplication *)application
{
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
