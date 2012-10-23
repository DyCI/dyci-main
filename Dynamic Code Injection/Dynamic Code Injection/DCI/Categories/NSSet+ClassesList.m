//
//  NSSet+ClassesList(Classes)
//  Dynamic Code Injection
//
//  Created by Paul Taykalo on 10/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "NSSet+ClassesList.h"


@implementation NSSet (ClassesList)

+ (NSMutableSet *)currentClassesSet {
   NSMutableSet * classesSet = [NSMutableSet set];

   int previousNumClasses = objc_getClassList(NULL, 0);
   Class * previousClasses = NULL;
   if (previousNumClasses > 0) {
      previousClasses = (Class *) malloc(sizeof(Class) * previousNumClasses);
      previousNumClasses = objc_getClassList(previousClasses, previousNumClasses);
      for (int i = 0; i < previousNumClasses; ++i) {
         [classesSet addObject:[NSValue value:&previousClasses[i] withObjCType:@encode(Class)]];
      }
      free(previousClasses);
   }
   return classesSet;
}

@end