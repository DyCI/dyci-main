//
// SFDYCIClangParams
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface SFDYCIClangParams : NSObject

@property(nonatomic, copy) NSString * className;
@property(nonatomic, copy) NSString * objectCompilation;
@property(nonatomic, copy) NSString * arch;
@property(nonatomic, copy) NSString * isysroot;
@property(nonatomic, strong) NSArray * LParams;
@property(nonatomic, strong) NSArray * FParams;
@property(nonatomic, copy) NSString * minOSParams;

- (NSString *)description;

@end