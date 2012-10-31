//
//  NSSet+ClassesList(Classes)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSSet (ClassesList)

/*
  Returns set of currently registered classes, wrapped with NSValue
 */
+ (NSMutableSet *)currentClassesSet;


@end