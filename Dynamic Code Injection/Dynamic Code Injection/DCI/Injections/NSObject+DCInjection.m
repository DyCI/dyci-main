//
//  NSObject(DCInjection)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import "NSObject+DCInjection.h"
#import "SFDynamicCodeInjection.h"


@implementation NSObject (DCInjection)

#pragma mark - Subscritption check

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
         if (className[1] == 'F') {
            return NO;
         }
         break;
      case 'U':
         if (className[1] == 'I') {
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

    id result = self;
    result = [result _swizzledInit];


   if (result) {

      if ([NSObject shouldPerformRuntimeCodeInjectionOnObject:result]) {

         id weakResult = result;

         NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];

         // On class update/inject
         [notificationCenter addObserverForName:SFDynamicRuntimeClassUpdatedNotification
                                         object:nil queue:nil usingBlock:^(NSNotification * note) {
            if ([weakResult isKindOfClass:note.object]) {
               [weakResult updateOnClassInjection];
            }
         }
         ];

         // On resource update/inject
         [notificationCenter addObserverForName:SFDynamicRuntimeResourceUpdatedNotification
                                         object:nil queue:nil usingBlock:^(NSNotification * note) {
            [weakResult updateOnResourceInjection:note.object];
         }

         ];
      }
   }
   return result;
}


- (void)_swizzledDealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   NSLog(@"Swizzled dealloc called");
   [self _swizzledDealloc];
}

@end
