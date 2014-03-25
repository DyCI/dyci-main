//
// SFDYCIXCodeHelper
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "SFDYCIXCodeHelper.h"
#import "CDRSXcodeDevToolsInterfaces.h"
#import "NSObject+Runtime.h"


@implementation SFDYCIXCodeHelper {

}
+ (SFDYCIXCodeHelper *)instance {
    static SFDYCIXCodeHelper * _instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (XC(IDEEditorContext))activeEditorContext {
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
    while (firstResponder) {
        firstResponder = [firstResponder nextResponder];

        NSLog(@"Responder is :%@", firstResponder);

        if ([firstResponder isKindOfClass:NSClassFromString(@"IDEEditorContext")]) {
            return (id<CDRSXcode_IDEEditorContext>) firstResponder;
        }
    }
    return nil;
}


- (NSURL *)activeDocumentFileURL {
    XC(IDEEditorContext) editorContext = [self activeEditorContext];
    if (editorContext) {

        // Resolving currently opened file
        NSURL * openedFileURL = [[[editorContext editor] document] fileURL];
        return openedFileURL;
    }

    return nil;
}


- (id<CDRSXcode_PBXTarget>)targetInOpenedProjectForFileURL:(NSURL *)fileURL {
    Class<XCP(PBXReference)> PBXReference = NSClassFromString(@"PBXReference");
    XC(PBXReference) selectedFileReference = [[PBXReference alloc] initWithPath: fileURL.path];

    Class<XCP(PBXProject>) PBXProject = NSClassFromString(@"PBXProject");
    NSArray * suggested_targets = [PBXProject targetsInAllProjectsForFileReference:selectedFileReference
                                                                        justNative:NO];

    NSLog(@"Targets : %@", suggested_targets);

    NSLog(@"Projects %@", [PBXProject openProjects] );

    // TODO: Find a better way to do it :)
    NSArray * activeRunContextTargetsIds = [NSClassFromString(@"IDEWorkspaceWindow")
      valueForKeyPath:
        @"lastActiveWorkspaceWindowController."
        "_workspace."
          "runContextManager."
          "activeRunContext."
          "buildSchemeAction."
          "buildActionEntries."
          "buildableReference."
          "blueprintIdentifier"];

    NSLog(@"ACtive Run Context Target sIDs %@", activeRunContextTargetsIds);
    // Go through all opened projects and find one with suggested target == it's active target
    for (XC(PBXTarget) suggestedTarget in suggested_targets) {
        NSObject * targetObjectID = [(id)suggestedTarget valueForKey:@"objectID"];
        NSLog(@"Suggsested target obejct ID %@", targetObjectID);
        if ([activeRunContextTargetsIds containsObject:targetObjectID]) {
            NSLog(@"Returning suggested target : %@ == %@", suggestedTarget, targetObjectID);
            return suggestedTarget;
        }
    }

    return nil;
}


@end