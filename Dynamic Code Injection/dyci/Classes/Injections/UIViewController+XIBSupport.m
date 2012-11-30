//
//  UIViewController+XIBSupport.m
//  Dynamic Code Ibjection
//
//  Created by Paul Taykalo on 11/30/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import "UIViewController+XIBSupport.h"

@implementation UIViewController (XIBSupport)

- (void)updateOnResourceInjection:(NSString *)path {
   
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

@end
