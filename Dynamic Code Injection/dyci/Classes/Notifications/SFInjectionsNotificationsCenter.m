//
//  SFInjectionsNotificationsCenter.m
//  dyci-framework
//
//  Created by Paul Taykalo on 6/1/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import "SFInjectionsNotificationsCenter.h"

#if TARGET_IPHONE_SIMULATOR

/*
 notification.object will be the class that was injected
 This notification is private due to discussion here https://github.com/DyCI/dyci-main/pull/51
 */
NSString * const SFInjectionsClassInjectedNotification = @"SFInjectionsClassInjectedNotification";

/*
 notification.object will be the resource that was injected
 This notification is private due to discussion here https://github.com/DyCI/dyci-main/pull/51
 */
NSString * const SFInjectionsResourceInjectedNotification = @"SFInjectionsResourceInjectedNotification";


@implementation SFInjectionsNotificationsCenter {
    NSMutableDictionary * _observers;
}


+ (instancetype)sharedInstance {
    static SFInjectionsNotificationsCenter * _instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!_instance) {
            _instance = [[self alloc] init];
            _instance->_observers = [NSMutableDictionary dictionary];
        }
    });
    return _instance;
}


- (void)addObserver:(id<SFInjectionObserver>)observer {
    [self addObserver:observer forClass:[observer class]];
}


- (void)removeObserver:(id<SFInjectionObserver>)observer {
    [self removeObserver:observer ofClass:[observer class]];
}


- (void)removeObserver:(id<SFInjectionObserver>)observer ofClass:(Class)aClass {
    @synchronized (_observers) {
        NSMutableSet * observersPerClass = [_observers objectForKey:aClass];
        if (observersPerClass) {
            @synchronized (observersPerClass) {
                [observersPerClass removeObject:observer];
            }
        }
    }
}


- (void)addObserver:(id<SFInjectionObserver>)observer forClass:(Class)aClass {
    if (!aClass) {
        return;
    }
    @synchronized (_observers) {
        NSMutableSet * observersPerClass = [_observers objectForKey:aClass];
        if (!observersPerClass) {
            observersPerClass = (__bridge_transfer NSMutableSet *) CFSetCreateMutable(nil, 0, nil);
            [_observers setObject:observersPerClass forKey:aClass];
        }
        @synchronized (observersPerClass) {
            [observersPerClass addObject:observer];
        }
    }
}


/*
This will notify about class injection
 */
- (void)notifyOnClassInjection:(Class)injectedClass {

    [[NSNotificationCenter defaultCenter] postNotificationName:SFInjectionsClassInjectedNotification object:injectedClass];

    int idx = 0;
    @synchronized (_observers) {
        for (NSMutableSet * observersPerClass in [_observers allValues]) {
            @synchronized (observersPerClass) {
                id anyObject = [observersPerClass anyObject];
                if (self.notificationStategy == SFInjectionNotificationStrategyInjectedClassOnly
                     && ![anyObject isKindOfClass:injectedClass]) {
                    continue;
                }
                for (id<SFInjectionObserver> observer in observersPerClass) {
                    [observer updateOnClassInjection];
                    idx++;
                }
            }
        }
    }
    
    NSLog(@"%d instanses were notified on Class Injection by injecting class: (%@)", idx, NSStringFromClass(injectedClass));
}


/*
This will notiy all registered classes about that some resource was injected
 */
- (void)notifyOnResourceInjection:(NSString *)resourceInjection {

    [[NSNotificationCenter defaultCenter] postNotificationName:SFInjectionsResourceInjectedNotification object:resourceInjection];

    int idx = 0;
    @synchronized (_observers) {
        for (NSMutableSet * observersPerClass in [_observers allValues]) {
            @synchronized (observersPerClass) {
                for (id<SFInjectionObserver> observer in observersPerClass) {
                    [observer updateOnResourceInjection:resourceInjection];
                    idx++;
                }
            }
        }
    }
    NSLog(@"%d classes instanses were notified on REsource Injection", idx);
}


@end


#endif