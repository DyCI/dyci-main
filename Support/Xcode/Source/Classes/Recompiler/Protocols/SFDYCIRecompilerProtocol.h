//
// SFDYCIRecompilerProtocol
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>

/*

 */
@protocol SFDYCIRecompilerProtocol<NSObject>

/*
Performs recompilation for specified fileURL
Completion block should be called on the comletion.
NSError should be filled in if recompilation fails
 */
- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void(^)(NSError * error))completionBlock;

/*
Returns if file at specified url can be recompiled
 */
- (BOOL)canRecompileFileAtURL:(NSURL *)fileURL;


@end