//
//  NSObject+DyCInjection(DCInjection)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR

#import <objc/runtime.h>
#import "NSObject+DyCInjection.h"
#import "SFDynamicCodeInjection.h"


void swizzle(Class c, SEL orig, SEL new) {
   Method origMethod = class_getInstanceMethod(c, orig);
   Method newMethod = class_getInstanceMethod(c, new);
   if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
      class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
   } else {
      method_exchangeImplementations(origMethod, newMethod);
   }
}



@implementation NSObject (DyCInjection)

#pragma mark - Swizzling

+ (void)allowInjectionSubscriptionOnInitMethod {
   swizzle([NSObject class], @selector(init), @selector(_swizzledInit));
   swizzle([NSObject class], NSSelectorFromString(@"dealloc"), @selector(_swizzledDealloc));
}


#pragma mark - Subscription check

+ (BOOL)shouldPerformRuntimeCodeInjectionOnObject:(__unsafe_unretained id)instance {
   if (!instance) {
      return NO;
   }

#warning We should skip more than just NS, CF, and private classes
   char const * className = object_getClassName(instance);
   switch (className[0]) {
      case '_':
         return NO;
      case 'N':
         if (className[1] == 'S') {
            return NO;
         }
         break;
      case 'C':
         if (className[1] == 'A' ||
             className[1] == 'F' ) {
            return NO;
         }
         break;
      case 'U':
         if (className[1] == 'I') {
            return NO;
         }
         break;
      case 'W':
         if (className[1] == 'e' && className[2] == 'b') {
            return NO;
         }
         break;

      default:
         break;
   }

   return YES;
}

#pragma mark - On Injection methods

- (void)updateOnClassInjection {

}


- (void)updateOnResourceInjection:(NSString *)resourcePath {

}


#pragma  mark - Swizzled methods

- (id)_swizzledInit {

   // Calling previous init

   id result = self;
   result = [result _swizzledInit];

   if (result) {

      // In case, if we are in need to inject
      if ([NSObject shouldPerformRuntimeCodeInjectionOnObject:result]) {

         NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];

         // On class update/inject
         [notificationCenter addObserver:self selector:@selector(onClassUpdateNotification:) name:SFDynamicRuntimeClassUpdatedNotification object:nil];
         [notificationCenter addObserver:self selector:@selector(onResourceUpdateNotification:) name:SFDynamicRuntimeResourceUpdatedNotification object:nil];

      }

   }
   return result;
}

- (void)_swizzledDealloc {

   if ([NSObject shouldPerformRuntimeCodeInjectionOnObject:self]) {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
   }

   // Swizzled methods are fun
   // Calling previous dealloc implementation
   [self _swizzledDealloc];

}


#pragma  mark - Notifications handling

- (void)onClassUpdateNotification:(NSNotification *)note {
   if ([self isKindOfClass:note.object]) {
      [self updateOnClassInjection];
   }
}


- (void)onResourceUpdateNotification:(NSNotification *)note {
   [self updateOnResourceInjection:note.object];
}


@end

#endif
