//
// SFDYCIXCodeHelper
// SFDYCIPlugin
//
// Created by Paul Taykalo on 3/24/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
#import <AppKit/AppKit.h>
#import "SFDYCIXCodeHelper.h"


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


@end