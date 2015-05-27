//
//  SFDYCIHelper.h
//  SFDYCIHelper
//
//  Created by Paul Taykalo on 09/07/12.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface IDEEditorContext : NSObject
- (id)editor;
@end

@interface IDEEditorDocument : NSDocument
- (void)ide_saveDocument:(id)arg1;
@end

@interface IDEEditorArea : NSObject
- (IDEEditorContext *)lastActiveEditorContext;
@property(readonly) IDEEditorDocument *primaryEditorDocument;
@end

@interface IDENavigatorArea : NSObject
- (id)currentNavigator;
@end

@interface IDEWorkspaceTabController : NSObject
@property (readonly) IDENavigatorArea *navigatorArea;
@end

@interface IDEWorkspaceWindowController : NSObject
@property (readonly) IDEWorkspaceTabController *activeWorkspaceTabController;
- (IDEEditorArea *)editorArea;
@end


@interface SFDYCIHelper : NSObject {
	
}



@end
