//
// SFDYCIClangParamsExtractor
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
@class SFDYCIClangParams;


@interface SFDYCIClangParamsExtractor : NSObject

- (SFDYCIClangParams *)extractParamsFromArguments:(NSArray *)arguments;

@end