//
//  SFInjectionsNotificationsCenter.h
//  dyci-framework
//
//  Created by Paul Taykalo on 6/1/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR

/*
 
 You can observe for changes in any class by saying

 #if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(classInjectionNotification:) name:@"SFInjectionsClassInjectedNotification" object:nil];
 #endif
 
 Or by specifying a specific class

 #if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myViewControllerClassInjectionNotification:) name:@"SFInjectionsClassInjectedNotification" object:(id)[MyViewController class]];
 #endif
 
 */


@protocol SFInjectionObserver <NSObject>

/*
  Will be called, when some class (X) will be injected in application runtime
  On All instances of class X, and instances of subclasses of X, this method will be called
*/
- (void)updateOnClassInjection;

/*
  This method will be called for all classes, that are waiting for resources changes.
  Before this method is called, Image cache is flushed, so you don't have to call memory warnings
  Resource that was injected is passed with parameter. But in general, you don't need to care
*/
- (void)updateOnResourceInjection:(NSString *)resourcePath;

@end


/*
 Notification strategy on injection.
 */
typedef NS_ENUM(NSUInteger, SFInjectionNotificationStrategy) {
    /**
     Notifies only instances class X and all subclasses of X
     */
    SFInjectionNotificationStrategyInjectedClassOnly,
    /**
     Notifies all classes about injection
     */
    SFInjectionNotificationStrategyAllClasses,
};

/*
This notification center will notify classes about new infection code available
Live classes about new code
This one was made because it seems sometimes classes doesn't remove themself as observers from
Notification Center. And we'll try to understand why it's so

Also it'll try to understand which classes should be filtered from observing
 */
@interface SFInjectionsNotificationsCenter : NSObject

/*
 Decides which classes should be notified on injection.
 Default value is SFInjectionNotificationStrategyInjectedClassOnly
 */
@property(nonatomic, assign) SFInjectionNotificationStrategy notificationStategy;

/*
Returns notification center instance
 */
+ (instancetype)sharedInstance;

- (void)addObserver:(id<SFInjectionObserver>)observer;
- (void)removeObserver:(id<SFInjectionObserver>)observer;

/*
This will notify about class injection
 */
- (void)notifyOnClassInjection:(Class)aClass;

/*
This will notiy all registered classes about that some resource was injected
 */
- (void)notifyOnResourceInjection:(NSString *)resourceInjection;

@end

#endif