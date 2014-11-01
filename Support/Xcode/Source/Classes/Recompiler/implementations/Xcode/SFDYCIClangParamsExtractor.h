//
// SFDYCIClangParamsExtractor
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
@class SFDYCIClangParams;


/*
Object that is responsibel for extracting parameters those are needed to
perform successful recompilation
 */
@interface SFDYCIClangParamsExtractor : NSObject

/*
Extracts parameters from specified array of arguments
 */
- (SFDYCIClangParams *)extractParamsFromArguments:(NSArray *)arguments;

@end