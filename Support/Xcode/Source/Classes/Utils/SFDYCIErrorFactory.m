//
// SFDYCIErrorFactory
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import "SFDYCIErrorFactory.h"

NSString * SFDYCIErrorDomain = @"com.stanfy.dyci";
typedef NS_ENUM(NSUInteger , SFDYCIErrorCode) {
    SFDYCIErrorCodeUnknown = 0,
    SFDYCIErrorCodeCompilationFailed = -100,
    SFDYCIErrorCodeDlybCreatoinFailed = -200,
};

@implementation SFDYCIErrorFactory {

}
+ (NSError *)compilationErrorWithMessage:(NSString *)message {
    return [[NSError alloc] initWithDomain:SFDYCIErrorDomain
                                      code:SFDYCIErrorCodeCompilationFailed
                                  userInfo: message ? @{NSLocalizedDescriptionKey : message} : nil];
}


+ (NSError *)dylibCreationErrorWithMessage:(NSString *)message {
    return [[NSError alloc] initWithDomain:SFDYCIErrorDomain
                                      code:SFDYCIErrorCodeDlybCreatoinFailed
                                  userInfo: message ? @{NSLocalizedDescriptionKey : message} : nil];
}


@end