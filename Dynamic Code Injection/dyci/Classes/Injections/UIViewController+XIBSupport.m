//
//  UIViewController+XIBSupport.m
//  Dynamic Code Ibjection
//
//  Created by Paul Taykalo on 11/30/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import "UIViewController+XIBSupport.h"
#import "SFDynamicCodeInjection.h"

@interface SFDynamicCodeInjection (Private)

+ (id)sharedInstance;
- (void)flushBundleCache:(NSBundle *)bundle;

@end


@implementation UIViewController (XIBSupport)

- (void)updateOnResourceInjection:(NSString *)path {
   NSString * extension = [path pathExtension];
   if ([extension isEqualToString:@"nib"] ||
       [extension isEqualToString:@"xib"]) {
      [self updateOnXIBInjectionWithPath:path];
   }
   
   if ([extension isEqualToString:@"storyboardc"]) {
      [self updateOnStoryboardInjectionWithPath:path];
   }
   
}


- (void)updateOnXIBInjectionWithPath:(NSString *)path {
   NSString * resourceName = [[path lastPathComponent] stringByDeletingPathExtension];
   NSString * nibName = [self nibName];
   
   // Checking if it is our nib was ibjected
   if ([nibName isEqualToString:resourceName]) {
      
      // If so... let's check if we loaded our view already
      
      if ([self isViewLoaded]) {
         
         // Saving view "state"
         CGRect oldFrame = self.view.frame;
         UIView * superview = self.view.superview;
         NSUInteger index = [[superview subviews] indexOfObject:self.view];
         
         // Removing it from the superview
         [[self view] removeFromSuperview];
         
         // Reinitializing controller with new nib
         [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
         
         // Resouring view state
         [superview insertSubview:self.view atIndex:index];
         self.view.frame = oldFrame;
         
      } else  {
         
         // If view wasn't loaded yet, then simply reinializing contoller with new xib
         [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
         
      }
   }
}


- (void)updateOnStoryboardInjectionWithPath:(NSString *)path {
   NSString * name = [[path lastPathComponent] stringByDeletingPathExtension];
   UIStoryboard * injectedStoryBoard = [UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]];
   if (self.storyboard && injectedStoryBoard) {
      // Keys
      NSString * kBundle = @"bundle";
      NSString * kStoryboardFileName = @"storyboardFileName";
      NSString * kDesignatedEntryPointIdentifier = @"designatedEntryPointIdentifier";
      NSString * kIdentifierToNibNameMap = @"identifierToNibNameMap";
      NSString * kIdentifierToUINibMap = @"identifierToUINibMap";

      NSBundle * storyboardBundle = [self.storyboard valueForKey:kBundle];
      [[SFDynamicCodeInjection sharedInstance] flushBundleCache:storyboardBundle];
      
      NSString * injectedFileName = [injectedStoryBoard valueForKey:kStoryboardFileName];
      NSString * originalFileName = [self.storyboard valueForKey:kStoryboardFileName];
      if ([injectedFileName isEqualToString:originalFileName]) {
         
         // Let's use KVO in inappropriate way
         for (NSString * key in @[ kDesignatedEntryPointIdentifier, kIdentifierToNibNameMap, kIdentifierToUINibMap ]) {
            id value = [injectedStoryBoard valueForKey:key];
            [[self storyboard] setValue:value forKey:key];
         }
      }
   }
   
  
}

@end
