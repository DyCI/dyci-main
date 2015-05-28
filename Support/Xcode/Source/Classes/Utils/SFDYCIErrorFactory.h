//
// SFDYCIErrorFactory
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/27/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString * SFDYCIErrorDomain;

@interface SFDYCIErrorFactory : NSObject

+ (NSError *)compilationErrorWithMessage:(NSString *)message;
+ (NSError *)dylibCreationErrorWithMessage:(NSString *)message;
+ (NSError *)noRecompilerFoundErrorForFileURL:(NSURL *)fileURL;

@end