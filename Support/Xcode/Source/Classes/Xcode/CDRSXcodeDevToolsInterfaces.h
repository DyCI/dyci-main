//
// CDRSXcodeDevToolsInterfaces
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/25/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
// MOst header information was received from here
//
// https://github.com/luisobo/Xcode5-RuntimeHeaders
//
#import <Foundation/Foundation.h>
#import "CDRSXcodeInterfaces.h"


#pragma mark - Project structure

@protocol XCP(PBXReference)<NSObject>

+ (id)alloc;
- (id)initWithPath:(NSString *)path;

@end


@protocol XCP(PBXTargetBuildContext)

- (NSArray *)commands;

@end

@protocol XCP(PBXTarget)

- (XC(PBXTargetBuildContext))targetBuildContext;

@end


@protocol XCP(XCDependencyCommand)

- (NSArray *)ruleInfo;
- (NSString *)commandPath;
- (NSArray *)arguments;
- (NSDictionary *)environment;
- (id)toolSpecification;
- (NSString *)workingDirectoryPath;

// :))
- (void)rerunCommand;


@end


@protocol XCP(PBXProject)

+ (NSArray *)targetsInAllProjectsForFileReference:(XC(PBXReference))fileReference justNative:(BOOL)nativeOnly;
+ (NSArray *)openProjects;

- (XC(PBXTarget))activeTarget;
+ (XC(PBXProject))projectWrapperPathForPath:(NSString *)path;

@end


