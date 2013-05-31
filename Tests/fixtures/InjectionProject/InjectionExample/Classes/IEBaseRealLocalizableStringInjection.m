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
   NSLog(@"Localizable String Test File Injected");
}

- (void)updateOnResourceInjection:(NSString *)path {
   NSString * localizableString = [[NSBundle mainBundle] localizedStringForKey:@"Key" value:@"This wasn't really injected :(" table:@"ReallyLocalizable"];
   NSLog(@"Localizable strings : %@", localizableString);
}

@end
