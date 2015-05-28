#import <sys/cdefs.h>//
//  SFDYCIPlugin.m
//  SFDYCIPlugin
//
//  Created by Paul Taykalo on 09/07/12.
//
//

#import "SFDYCIPlugin.h"
#import "SFDYCIXCodeHelper.h"
#import "SFDYCIClangProxyRecompiler.h"
#import "SFDYCIXcodeObjectiveCRecompiler.h"
#import "SFDYCIViewsHelper.h"
#import "SFDYCICompositeRecompiler.h"
#import "DYCI_CCPXCodeConsole.h"


@interface SFDYCIPlugin ()
@property(nonatomic, strong) id <SFDYCIRecompilerProtocol> recompiler;
@property(nonatomic, strong) SFDYCIViewsHelper *viewHelper;
@property(nonatomic, strong) SFDYCIXCodeHelper *xcodeStructureManager;
@end


@implementation SFDYCIPlugin

#pragma mark - Plugin Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}


- (id)init {
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        // Waiting for application start
        [notificationCenter addObserver:self
                               selector:@selector(applicationDidFinishLaunching:)
                                   name:NSApplicationDidFinishLaunchingNotification
                                 object:nil];
    }
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"App finished launching");

    // Selecting Xcode Recompiler first
    // We'll use Xcode recompiler, and if that one fails, we'll fallback to dyci-recompile.py
    self.recompiler = [[SFDYCICompositeRecompiler alloc]
        initWithCompilers:@[[SFDYCIXcodeObjectiveCRecompiler new], [SFDYCIClangProxyRecompiler new]]];

    self.viewHelper = [SFDYCIViewsHelper new];

    self.xcodeStructureManager = [SFDYCIXCodeHelper instance];

    [self setupMenu];

}

#pragma mark - Preferences

- (void)setupMenu {
    NSMenuItem *runMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (runMenuItem) {

        NSMenu *subMenu = [runMenuItem submenu];

        // Adding separator
        [subMenu addItem:[NSMenuItem separatorItem]];

        // Adding inject item
        NSMenuItem *recompileAndInjectMenuItem = [[NSMenuItem alloc] initWithTitle:@"Recompile and inject" action:@selector(recompileAndInject:) keyEquivalent:@"x"];
        [recompileAndInjectMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        [recompileAndInjectMenuItem setTarget:self];

        [subMenu addItem:recompileAndInjectMenuItem];

        NSMenuItem *verboseRecompilationItem = [[NSMenuItem alloc] initWithTitle:@"Use verbose recompilation" action:@selector(useVerboseRecompilationAction:) keyEquivalent:@""];
        [verboseRecompilationItem setTarget:self];
        [subMenu addItem:verboseRecompilationItem];


    }
}

- (void)useVerboseRecompilationAction:(NSMenuItem *)useVerboseRecompilationItem {
    DYCI_CCPXCodeConsole * console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    if (useVerboseRecompilationItem.state == NSOffState) {
        useVerboseRecompilationItem.state = NSOnState;
        [console log:@"DYCI verbose recompilation turned ON"];
        console.shouldShowDebugInfo = YES;
    } else {
        useVerboseRecompilationItem.state = NSOffState;
        console.shouldShowDebugInfo = NO;
        [console log:@"DYCI verbose recompilation turned OFF"];
    }
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // TODO : We need correct checks, when we can use Inject, and where we cannot
    // Validate when we need to be called
    //   if ([menuItem action] == @selector(recompileAndInject:)) {
    //      NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
    //
    //      NSLog(@"Validation check");
    //      while (firstResponder) {
    //         firstResponder = [firstResponder nextResponder];
    //         NSLog(@"firstResponder = %@", firstResponder);
    //      }
    //      return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
    //   }
    return YES;
}


- (void)recompileAndInject:(id)sender {
    NSDocument<CDRSXcode_IDEEditorDocument> *currentDocument = (NSDocument<CDRSXcode_IDEEditorDocument> *)[self.xcodeStructureManager currentDocument];
    if ([currentDocument isDocumentEdited]) {
        [currentDocument saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:nil];
    } else {
        [self recompileAndInjectAfterSave:nil];
    }

}

- (void)document:(NSDocument *)document didSave:(BOOL)didSaveSuccessfully contextInfo:(void *)contextInfo {
    [self recompileAndInjectAfterSave:nil];
}


- (void)recompileAndInjectAfterSave:(id)sender {
    DYCI_CCPXCodeConsole * console = [DYCI_CCPXCodeConsole consoleForKeyWindow];
    [console log:@"Starting Injection"];
    __weak SFDYCIPlugin *weakSelf = self;


    NSURL *openedFileURL = self.xcodeStructureManager.activeDocumentFileURL;

    if (openedFileURL) {

        [console log:[NSString stringWithFormat:@"Injecting %@(%@)", openedFileURL.lastPathComponent, openedFileURL]];

        [self.recompiler recompileFileAtURL:openedFileURL completion:^(NSError *error) {
            if (error) {
                [weakSelf.viewHelper showError:error];
                [console error:[NSString stringWithFormat:@"Recompilation failed %@", error]];
            } else {
                [weakSelf.viewHelper showSuccessResult];
                [console log:@"Recompilation was successful"];
            }
        }];

    } else {
        [console error:[NSString stringWithFormat:@"Cannot inject this file right now. If you think that this file is injectable, try again bit later"]];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
