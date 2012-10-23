//
//  DCIAppDelegate.h
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCIViewController;

@interface DCIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DCIViewController *viewController;

@end
