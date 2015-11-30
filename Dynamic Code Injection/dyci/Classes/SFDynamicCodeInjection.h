//
//  SFDynamicCodeInjection
//  Nemlig-iPad
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SFDynamicCodeInjection : NSObject

/*
 Enables dynamic runtime
 */
+ (void)enable;

/*
 Disables dynamic runtime
*/
+ (void)disable;


#pragma mark - Settings

/*
 When this option enabled,
 all classes will be notified when injection happens
 */
+ (void)notifyAllClassesOnInjection;

/*
 When this option enabled,
 On injection of class X, only instances of class X, and it's sublcasses will be notified
 This is default behaviour.
 */
+ (void)notifyInjectedClassAndSubclassesOnInjection;



@end