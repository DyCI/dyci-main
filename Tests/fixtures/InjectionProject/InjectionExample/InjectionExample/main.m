//
//  main.m
//  InjectionExample
//
//  Created by Paul Taykalo on 2/24/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IEAppDelegate.h"
#import "objc/runtime.h"

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
      NSLog(@"Running Injection Example!");
      return UIApplicationMain(argc, argv, nil, @"IEAppDelegate");

   }
}
