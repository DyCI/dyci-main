//
// SFDYCIClangParams
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "SFDYCIClangParams.h"


@implementation SFDYCIClangParams {

}
- (NSString *)description {
    NSMutableString * description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.className=%@", self.className];
    [description appendFormat:@"self.objectCompilation=%@", self.objectCompilation];
    [description appendFormat:@", self.arch=%@", self.arch];
    [description appendFormat:@", self.isysroot=%@", self.isysroot];
    [description appendFormat:@", self.LParams=%@", self.LParams];
    [description appendFormat:@", self.FParams=%@", self.FParams];
    [description appendFormat:@", self.minOSParams=%@", self.minOSParams];
    [description appendString:@">"];
    return description;
}

@end