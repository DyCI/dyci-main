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
#import "DYCI_CCPXCodeConsole.h"


@interface SFDYCIXCodeHelper ()
@property(nonatomic, strong) DYCI_CCPXCodeConsole *console;
@end

@implementation SFDYCIXCodeHelper {

}
+ (SFDYCIXCodeHelper *)instance {
    static SFDYCIXCodeHelper *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
        }
    }

    return _instance;
}

- (XC(IDEEditorContext))activeEditorContext {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    while (firstResponder) {
        firstResponder = [firstResponder nextResponder];

        [self.console debug:[NSString stringWithFormat:@"Responder is :%@", firstResponder]];

        if ([firstResponder isKindOfClass:NSClassFromString(@"IDEEditorContext")]) {
            return (id <CDRSXcode_IDEEditorContext>) firstResponder;
        }
    }
    return nil;
}


- (NSURL *)activeDocumentFileURL {
    XC(IDEEditorContext) editorContext = [self activeEditorContext];
    if (editorContext) {

        // Resolving currently opened file
        NSURL *openedFileURL = [[[editorContext editor] document] fileURL];
        return openedFileURL;
    }

    return nil;
}


- (id <CDRSXcode_PBXTarget>)targetInOpenedProjectForFileURL:(NSURL *)fileURL {
    Class <XCP(PBXReference)> PBXReference = NSClassFromString(@"PBXReference");
    XC(PBXReference) selectedFileReference = [[PBXReference alloc] initWithPath:fileURL.path];

    Class <XCP(PBXProject >) PBXProject = NSClassFromString(@"PBXProject");
    NSArray *suggested_targets = [PBXProject targetsInAllProjectsForFileReference:selectedFileReference
                                                                       justNative:NO];

    [self.console debug:[NSString stringWithFormat:@"Targets : %@", suggested_targets]];

    [self.console debug:[NSString stringWithFormat:@"Projects %@", [PBXProject openProjects]]];

    // TODO: Find a better way to do it :)
    NSArray *activeRunContextTargetsIds = [NSClassFromString(@"IDEWorkspaceWindow")
        valueForKeyPath:
            @"lastActiveWorkspaceWindowController."
                "_workspace."
                "runContextManager."
                "activeRunContext."
                "buildSchemeAction."
                "buildActionEntries."
                "buildableReference."
                "blueprintIdentifier"];

    [self.console debug:[NSString stringWithFormat:@"ACtive Run Context Target sIDs %@", activeRunContextTargetsIds]];
    // Go through all opened projects and find one with suggested target == it's active target
    for (XC(PBXTarget) suggestedTarget in suggested_targets) {
        NSObject *targetObjectID = [(id) suggestedTarget valueForKey:@"objectID"];
        [self.console debug:[NSString stringWithFormat:@"Suggsested target obejct ID %@", targetObjectID]];
        if ([activeRunContextTargetsIds containsObject:targetObjectID]) {
            [self.console debug:[NSString stringWithFormat:@"Returning suggested target : %@ == %@", suggestedTarget, targetObjectID]];
            return suggestedTarget;
        }
    }

    return nil;
}

- (XC(IDEWorkspaceWindowController))workspaceWindowController {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return (XC(IDEWorkspaceWindowController)) currentWindowController;
    }
    return nil;
}


- (XC(IDEEditorDocument))currentDocument {
    XC(IDEWorkspaceWindowController) workspaceWindowController = [self workspaceWindowController];
    if (workspaceWindowController) {
        XC(IDEEditorArea) editorArea = [workspaceWindowController editorArea];
        return editorArea.primaryEditorDocument;
    }
    return nil;
}


@end