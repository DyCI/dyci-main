/*
 CDRSXCodeInterfaces.h
 originally was taken from https://github.com/cppforlife/CedarShortcuts
 */

#import <Foundation/Foundation.h>

@class NSDocument;

#pragma mark - Run contexts and destinations

#define XCP(type) CDRSXcode_##type
#define XC(type) id<CDRSXcode_##type>

@protocol XCP(DVTFilePath)
- (NSString *)pathString;
@end

@protocol XCP(RunContext)
- (BOOL)isTestable;
- (NSString *)name;
@end

@protocol XCP(RunDestination)
- (NSString *)fullDisplayName;
@end

@protocol XCP(RunContextManager)
- (XC(RunContext))activeRunContext;
- (NSArray *)runContexts;

- (XC(RunDestination))activeRunDestination;
- (NSArray *)availableRunDestinations;

- (void)setActiveRunContext:(XC(RunContext))context
          andRunDestination:(XC(RunDestination))destination;
@end

@protocol XCP(Workspace)
- (XC(RunContextManager))runContextManager;
- (XC(DVTFilePath))representingFilePath;
@end

@protocol XCP(IDEWorkspaceDocument)
- (NSArray *)recentEditorDocumentURLs;
@end

@protocol XCP(IDEWorkspaceTabController)
- (XC(IDEWorkspaceDocument))workspaceDocument;
@end

@protocol XCP(IDEEditorDocument)
- (void)ide_saveDocument:(id)arg1;
@end

@protocol XCP(IDEEditorArea)
- (XC(IDEEditorDocument))primaryEditorDocument;
@end

@protocol XCP(IDEWorkspaceWindowController)
- (XC(IDEWorkspaceTabController))activeWorkspaceTabController;
- (XC(IDEEditorArea))editorArea;

@end


#pragma mark - Session launching

@protocol XCP(IDELaunchParametersSnapshot)
// though env variables are exposed as NSDictionary* in Xcode headers
- (NSMutableDictionary *)environmentVariables;
- (NSMutableDictionary *)testingEnvironmentVariables;
- (void)setTestingEnvironmentVariables:(NSMutableDictionary *)variables;
@end

@protocol XCP(IDELaunchSession)
- (XC(IDELaunchParametersSnapshot))launchParameters;
@end


#pragma mark - Editors

@protocol XCP(DVTSourceExpression)
- (NSString *)symbolString;
@end

@protocol XCP(DVTSourceLandmarkItem)
- (NSRange)range;
- (NSString *)name;
@end

@protocol XCP(DVTSourceTextStorage)
- (NSArray *)importLandmarkItems;

- (NSUInteger)nextExpressionFromIndex:(unsigned long long)index
                              forward:(BOOL)forward;

- (void)replaceCharactersInRange:(NSRange)range
                      withString:(NSString *)string
                 withUndoManager:(id)undoManager;
@end

@protocol XCP(DVTTextDocumentLocation)

- (NSRange)characterRange;

@end


@protocol XCP(IDEEditor)
- (NSDocument *)document;
@end

@protocol XCP(IDEEditorContext)
- (XC(IDEEditor))editor;
@end


@protocol XCP(IDESourceCodeDocument)
// from NSDocument super class
- (NSURL *)fileURL;
- (XC(DVTSourceTextStorage))textStorage;
@end

@protocol XCP(IDESourceCodeEditor) <XCP(IDEEditor)>
- (XC(IDEEditorContext))editorContext;
- (XC(IDESourceCodeDocument))sourceCodeDocument;
- (XC(DVTSourceExpression))_expressionAtCharacterIndex:(NSRange)range;
- (NSArray *)currentSelectedDocumentLocations;
- (long long)_currentOneBasedLineNubmer;
@end



