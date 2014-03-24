//
// SFDYCIXCodeHelper
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CDRSXcodeInterfaces.h"


@interface SFDYCIXCodeHelper : NSObject

+ (SFDYCIXCodeHelper *)instance;

/*
 Current editor context
 */
- (XC(IDEEditorContext))activeEditorContext;

/*
Currently active opened file
 */
- (NSURL *)activeDocumentFileURL;

@end