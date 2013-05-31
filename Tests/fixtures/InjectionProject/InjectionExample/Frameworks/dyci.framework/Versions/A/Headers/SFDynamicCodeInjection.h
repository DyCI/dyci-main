//
//  SFDynamicCodeInjection
//  Nemlig-iPad
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <Foundation/Foundation.h>

static NSString * const SFDynamicRuntimeClassUpdatedNotification = @"DynamicClassUpdated";
static NSString * const SFDynamicRuntimeResourceUpdatedNotification = @"DynamicResourceUpdated";

/*
If we should inject update methods, we are adding self as observer for
  Two type of notifications
  SFDynamicRuntimeClassUpdatedNotification
     will be called, when some class (X) will be injected in application runtime
     All instances of class X, and instances of subclasses of X, will receive
     - (void)updateOnClassInjection


SFDynamicRuntimeResourceUpdatedNotification
    This notification will be posted, each time, when new resource will be available in
    bundle. With the main reason to not increase complexity, we aren't specifying, which resource
    was added
*/
@interface SFDynamicCodeInjection : NSObject

/*
 Enables dynamic runtime
 */
+ (void)enable;

/*
 Disables dynamic runtime
*/
+ (void)disable;


@end