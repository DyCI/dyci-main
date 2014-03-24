//
// SFDYCIRecompilerProtocol
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>


@protocol SFDYCIRecompilerProtocol<NSObject>

- (void)recompileFileAtURL:(NSURL *)fileURL completion:(void(^)(NSError * error))completionBlock;

@end