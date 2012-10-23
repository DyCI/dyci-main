//
//  DCIDynamicView.m
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/7/12.
//  Copyright (c) 2012 Stanfy. All rights reserved.
//

#import "DCIDynamicView.h"
#import "SFDynamicCodeInjection.h"

@implementation DCIDynamicView

- (id)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
   }

   return self;

}

- (void)updateOnClassInjection {
   [self setNeedsDisplay];
}


@end
