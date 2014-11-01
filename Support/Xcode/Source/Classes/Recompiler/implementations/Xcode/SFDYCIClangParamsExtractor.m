//
// SFDYCIClangParamsExtractor
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "SFDYCIClangParamsExtractor.h"
#import "SFDYCIClangParams.h"


@implementation SFDYCIClangParamsExtractor {

}
- (SFDYCIClangParams *)extractParamsFromArguments:(NSArray *)arguments {
    SFDYCIClangParams * clangParams = [SFDYCIClangParams new];
    NSMutableArray * LParams = [NSMutableArray array];
    clangParams.LParams = LParams;
    NSMutableArray * FParams = [NSMutableArray array];
    clangParams.FParams = FParams;
    [arguments enumerateObjectsUsingBlock:^(NSString * argument, NSUInteger idx, BOOL * stop) {

        if ([argument rangeOfString:@".*\\w+\\.mm?$" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.compilationObjectName = argument;
        } else if ([argument rangeOfString:@".*\\w+\\.o$" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.objectCompilationPath = argument;
        } else if ([argument rangeOfString:@"^-L.*" options:NSRegularExpressionSearch].location != NSNotFound) {
            [LParams addObject:argument];
        } else if ([argument rangeOfString:@"^-F.*" options:NSRegularExpressionSearch].location != NSNotFound) {
            [FParams addObject:argument];
        } else if ([argument rangeOfString:@"-arch" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.arch = arguments[idx + 1];
        } else if ([argument rangeOfString:@"-isysroot" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.isysroot = arguments[idx + 1];
        } else if ([argument rangeOfString:@"^-mi.*-min=.*" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.minOSParams = argument;
        } else if ([argument rangeOfString:@"^-mmacosx.*-min=.*" options:NSRegularExpressionSearch].location != NSNotFound) {
            clangParams.minOSParams = argument;
        }
    }];

    return clangParams;
}

@end