//
// SFDYCIXCodeHelper
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CDRSXcodeInterfaces.h"
#import "CDRSXcodeDevToolsInterfaces.h"

@class DYCI_CCPXCodeConsole;

/*
This is the helper that should know about xcode project.
No other parts of this project should know about Xcode project structure, about active targers whatever
 */
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

/*
Returns target for specified fileURL
 */
- (XC(PBXTarget))targetInOpenedProjectForFileURL:(NSURL *)fileURL;

/*
Returns active workspace window controller, if any
 */
- (XC(IDEWorkspaceWindowController))workspaceWindowController;

/*
Current editing document
 */
- (XC(IDEEditorDocument))currentDocument;


@end