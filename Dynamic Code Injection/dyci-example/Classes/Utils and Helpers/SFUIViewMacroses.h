//
//  Macroses.h
//  Jurliga
//
//  Created by Slavik Bubnov on 09.08.11.
//  Copyright 2011 Stanfy, LLC. All rights reserved.
//

/**
 Make UIView autoresize mask from string
 
 'T' = UIViewAutoresizingFlexibleTopMargin, 
 'L' = UIViewAutoresizingFlexibleLeftMargin
 'B' = UIViewAutoresizingFlexibleBottomMargin
 'R' = UIViewAutoresizingFlexibleRightMargin
 'W' = UIViewAutoresizingFlexibleWidth
 'H' = UIViewAutoresizingFlexibleHeight
 
 Any other characters considered as separators.
 For readability use '+' as separator.
 
 For example:
   self.view.autoresizeMask = UIViewAutoresizingMake(@"T+L+B+R+W+H");
   self.view.autoresizeMask = UIViewAutoresizingMake(@"WH");
 */
static UIViewAutoresizing UIViewAutoresizingMake(NSString *flagsString) {
   UIViewAutoresizing mask = UIViewAutoresizingNone;
   
   NSString *flags = [flagsString uppercaseString];
   
   for (int i = 0; i < [flags length]; i++) {
      NSString *flag = [flags substringWithRange:NSMakeRange(i, 1)];
      
      if ([@"T" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleTopMargin;
      else if ([@"B" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleBottomMargin;
      else if ([@"L" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleLeftMargin;
      else if ([@"R" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleRightMargin;
      else if ([@"W" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleWidth;
      else if ([@"H" isEqualToString:flag]) mask |= UIViewAutoresizingFlexibleHeight;
   }
   
   return mask;
}


// Shortcut for autoreaizing mask of resizable at all direction view 
#define  UIViewAutoresizingAll   UIViewAutoresizingMake(@"T+R+B+L+W+H")