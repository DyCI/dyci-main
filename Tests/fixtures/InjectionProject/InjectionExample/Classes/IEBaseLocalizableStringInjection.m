//
//  IEBaseLocalizableStringInjection.m
//  InjectionExample
//
//  Created by Paul Taykalo on 3/3/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import "IEBase.h"

@implementation IEBase

- (void)updateOnClassInjection {
   NSLog(NSLocalizedString(@"Key", @"Key that will be re-injected"));
}

@end
