//
//  SFDynamicCodeInjection
//  Nemlig-iPad
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "SFDynamicCodeInjection.h"
#include <dlfcn.h>
#import "SFFileWatcher.h"
#import "SFFileWatcherDelegate.h"
#import "NSSet+ClassesList.h"

void swizzle(Class c, SEL orig, SEL new) {
   Method origMethod = class_getInstanceMethod(c, orig);
   Method newMethod = class_getInstanceMethod(c, new);
   if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
      class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
   else
      method_exchangeImplementations(origMethod, newMethod);
}


@interface SFDynamicCodeInjection () <SFFileWatcherDelegate>

@end



@implementation SFDynamicCodeInjection {

   BOOL _enabled;

   SFFileWatcher * _dciDirectoryFileWatcher;

}

+ (SFDynamicCodeInjection *)sharedInstance {
   static SFDynamicCodeInjection * _instance = nil;

   @synchronized (self) {
      if (_instance == nil) {
         _instance = [[self alloc] init];
      }
   }

   return _instance;
}


+ (void)enable {
#if TARGET_IPHONE_SIMULATOR

   if (![self sharedInstance]->_enabled) {
      
      [self sharedInstance]->_enabled = YES;

      // Swizzling init and dealloc methods
      [self allowInjectionSubscriptionOnInitMethod];

      NSString * dciDirectoryPath = [self dciDirectoryPath];

      // Saving application bundle path, to have ability to inject
      // Resources, xibs, etc
      [self saveCurrentApplicationBundlePath:dciDirectoryPath];


      // Setting up watcher, to get in touch with director contents
      [self sharedInstance]->_dciDirectoryFileWatcher =
       [SFFileWatcher fileWatcherWithPath:dciDirectoryPath
                                 delegate:[self sharedInstance]];
   }
#else

  // Nothing to do .. for now on the device :)
  #endif

}


+ (void)disable {
   if ([self sharedInstance]->_enabled) {
      [self sharedInstance]->_enabled = NO;
   }
}


#pragma mark - Checking for Library

+ (NSString *)dciDirectoryPath {
   NSString * dciDirectoryPath = [@"~" stringByExpandingTildeInPath];
   NSRange r = [dciDirectoryPath rangeOfString:@"/Library/Application Support"];
   dciDirectoryPath = [dciDirectoryPath substringToIndex:r.location];
   dciDirectoryPath = [dciDirectoryPath stringByAppendingPathComponent:@".dci"];
   dciDirectoryPath = [dciDirectoryPath stringByAppendingString:@"/"];
   return dciDirectoryPath;
}


#pragma mark - Injections

/*
 Injecting in all classes, that were found in specified set
 */
- (void)performInjectionWithClassesInSet:(NSMutableSet *)classesSet {

   for (NSValue * classWrapper in classesSet) {
      Class clz;
      [classWrapper getValue:&clz];
      NSString * className = NSStringFromClass(clz);

      if ([className hasPrefix:@"__"] && [className hasSuffix:@"__"]) {
         // Skip some O_o classes

      } else {

         [self performInjectionWithClass:clz];
         NSLog(@"Class was successfully injected");

      }
   }
}



- (void)performInjectionWithClass:(Class)injectedClass {
   // Parsing it's method

   // This is really funny
   // Even if we load two instances of classes with the same name :)
   // NSClassFromString Will return FIRST(Original) Instance. And this is cool! // RLY?
   NSString * className = [NSString stringWithFormat:@"%s", class_getName(injectedClass)];
   Class originalClass = NSClassFromString(className);

   // Replacing instance methods
   [self replaceMethodsOfClass:originalClass withMethodsOfClass:injectedClass];

   // Additionally we need to update Class methods (not instance methods) implementations
   [self replaceMethodsOfClass:object_getClass(originalClass) withMethodsOfClass:object_getClass(injectedClass)];


   // Notifying about new classes logic
    NSLog(@"Class (%@) and their subclasses instances would be notified with", NSStringFromClass(originalClass));
    NSLog(@" - (void)updateOnClassInjection ");

   [[NSNotificationCenter defaultCenter] postNotificationName:SFDynamicRuntimeClassUpdatedNotification
                                                       object:originalClass];

}


- (void)replaceMethodsOfClass:(Class)originalClass withMethodsOfClass:(Class)injectedClass {
   if (originalClass != injectedClass) {

      NSLog(@"Injecting %@ class : %@", class_isMetaClass(injectedClass) ? @"meta" : @"", NSStringFromClass(injectedClass));

      // Original class methods

      int i = 0;
      unsigned int mc = 0;

      NSMutableSet * injectedSelectors = [NSMutableSet set];
      Method * injectedMethodsList = class_copyMethodList(injectedClass, &mc);
      for (i = 0; i < mc; i++) {
         NSString * selectorName = [NSString stringWithFormat:@"%s",
                                                              sel_getName(method_getName(injectedMethodsList[i]))];
         [injectedSelectors addObject:selectorName];

         SEL injectedSelector = NSSelectorFromString(selectorName);

         Method m = injectedMethodsList[i];
         const char * types = method_getTypeEncoding(m);
         SEL name = method_getName(m);
         IMP imp = method_getImplementation(m);

         class_replaceMethod(originalClass, injectedSelector, imp, types);

      }

   }
}



#pragma mark - Helpers

+ (void)saveCurrentApplicationBundlePath:(NSString *)dciPath {

   NSString * filePathWithBundleInformation = [dciPath stringByAppendingPathComponent:@"bundle"];

   NSString * mainBundlePath = [[NSBundle mainBundle] resourcePath];
   [mainBundlePath writeToFile:filePathWithBundleInformation
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
}

- (void)flushUIImageCache {
#warning Fix this
   [UIImage performSelector:@selector(_flushSharedImageCache)];

}


#pragma mark - SFLibWatcherDelegate

- (void)newFileWasFoundAtPath:(NSString *)filePath {

   if ([[filePath lastPathComponent] isEqualToString:@"resource"]) {

      // Flushing UIImage cache
      [self flushUIImageCache];

      NSLog(@" ");
      NSLog(@" ================================================= ");
      NSLog(@"New resource was injected");
      NSLog(@"All classes will be notified with");
      NSLog(@" - (void)updateOnResourceInjection:(NSString *)path ");
      NSLog(@" ");


      NSString * injectedResourcePath =
       [NSString stringWithContentsOfFile:filePath
                                 encoding:NSUTF8StringEncoding
                                    error:nil];

      [[NSNotificationCenter defaultCenter] postNotificationName:SFDynamicRuntimeResourceUpdatedNotification
                                                          object:injectedResourcePath];

   }

   // If its library
   // Sometimes... we got notification with temporary file
   // dci12123.dylib.ld_1237sj
   NSString * dciDynamicLibraryPath = filePath;
   if (![[dciDynamicLibraryPath pathExtension] isEqualToString:@"dylib"]) {
      dciDynamicLibraryPath = [dciDynamicLibraryPath stringByDeletingPathExtension];
   }
   if ([[dciDynamicLibraryPath pathExtension] isEqualToString:@"dylib"]) {
      NSLog(@" ");
      NSLog(@" ================================================= ");
      NSLog(@"Found new DCI ... Loading");
      
      NSMutableSet * classesSet = [NSMutableSet currentClassesSet];
      
      void * libHandle = dlopen([dciDynamicLibraryPath cStringUsingEncoding:NSUTF8StringEncoding],
                                RTLD_NOW | RTLD_GLOBAL);
      char * err = dlerror();
      
      if (libHandle) {
         
         NSLog(@"DCI was successfully loaded");
         NSLog(@"Searching classes to inject");

         // Retrieving difference between old classes list and
         // current classes list
         NSMutableSet * currentClassesSet = [NSMutableSet currentClassesSet];
         [currentClassesSet minusSet:classesSet];

         [self performInjectionWithClassesInSet:currentClassesSet];
         
      } else {
         NSLog(@"Couldn't load file Error : %s", err);
      }

      NSLog(@" ");

      dlclose(libHandle);
   }
}


#pragma mark - Swizzling

+ (void)allowInjectionSubscriptionOnInitMethod {
   swizzle([NSObject class], @selector(init), @selector(_swizzledInit));
   swizzle([NSObject class], NSSelectorFromString(@"dealloc"), @selector(_swizzledDealloc));
}


@end