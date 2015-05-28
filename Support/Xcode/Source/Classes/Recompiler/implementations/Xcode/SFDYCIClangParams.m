//
// SFDYCIClangParams
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "SFDYCIClangParams.h"


@implementation SFDYCIClangParams

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@" compilationObjectName=%@", self.compilationObjectName];
    [description appendFormat:@" objectCompilationPath=%@", self.objectCompilationPath];
    [description appendFormat:@", arch=%@", self.arch];
    [description appendFormat:@", isysroot=%@", self.isysroot];
    [description appendFormat:@", LParams=%@", self.LParams];
    [description appendFormat:@", FParams=%@", self.FParams];
    [description appendFormat:@", minOSParams=%@", self.minOSParams];
    [description appendString:@">"];
    return description;
}

@end