//
//  IEBase.h
//  InjectionExample
//
//  Created by Paul Taykalo on 2/28/13.
//  Copyright (c) 2013 Stanfy. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 Base file that going to be injected
 */
@interface IEBase : NSObject

+ (void)classMethod;

- (void)instanceMethod;

- (void)printLocalizableString;

@end
