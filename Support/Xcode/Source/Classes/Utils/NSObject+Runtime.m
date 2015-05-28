//
// NSObject(Runtime)
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/25/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "NSObject+Runtime.h"
#import <objc/runtime.h>


@implementation NSObject (Runtime)

- (NSArray *)allPropertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);

    NSMutableArray *rv = [NSMutableArray array];

    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }

    free(properties);

    return rv;
}

- (void)printMethodsList {
    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(object_getClass([self class]), &mc);
    NSLog(@"%d methods", mc);
    for(i=0;i<mc;i++)
        NSLog(@"Method no #%d: + %s", i, sel_getName(method_getName(mlist[i])));
    free(mlist);
    
    i=0;
    mc = 0;
    mlist = class_copyMethodList([self class], &mc);
    NSLog(@"%d methods", mc);
    for(i=0;i<mc;i++)
        NSLog(@"Method no #%d: -%s", i, sel_getName(method_getName(mlist[i])));
    free(mlist);

}
@end