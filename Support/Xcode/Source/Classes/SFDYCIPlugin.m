//
//  SFDYCIPlugin.m
//  SFDYCIPlugin
//
//  Created by Paul Taykalo on 09/07/12.
//
//

#import "SFDYCIPlugin.h"
#import "SFDYCIResultView.h"
#import "CDRSXcodeInterfaces.h"
#import "SFDYCIXCodeHelper.h"
#import "SFDYCIClangProxyRecompiler.h"
#import "SFDYCIXcodeRuntimeRecompiler.h"


@interface SFDYCIPlugin ()
/*
Array of recompilers those can be used to perform recompilation
All of those checked if file at specified URL can ber recompiled
 */
@property(nonatomic, strong) NSArray * recompilers;

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
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];

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
    [self setupMenu];
    //We'll use Xcode recompiler, and if that one fails, we'll fallback to dyci-recompile.py
    self.recompilers = @[ [SFDYCIXcodeRuntimeRecompiler new], [SFDYCIClangProxyRecompiler new] ];

}

#pragma mark - Preferences

- (void)setupMenu {
    NSMenuItem *runMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (runMenuItem) {

        NSMenu *subMenu = [runMenuItem submenu];

        // Adding separator
        [subMenu addItem:[NSMenuItem separatorItem]];

        // Adding inject item
        NSMenuItem *recompileAndInjectMenuItem =
            [[NSMenuItem alloc] initWithTitle:@"Recompile and inject"
                                       action:@selector(recompileAndInject:)
                                keyEquivalent:@"x"];
        [recompileAndInjectMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        [recompileAndInjectMenuItem setTarget:self];
        [subMenu addItem:recompileAndInjectMenuItem];

    }
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // TODO : We need correct checks, when we can use Ibject, and where we cannot
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
    NSLog(@"Yupee :),  ");

    // Searching our IDEEditorContext
    // This class has information about URL of file that being edited
    SFDYCIXCodeHelper * xcode = [SFDYCIXCodeHelper instance];
    NSURL * openedFileURL = [xcode activeDocumentFileURL];
    if (openedFileURL) {

        NSLog(@"Opened file url is : %@", openedFileURL);
        // Setting up task, that we are going to call

        id<SFDYCIRecompilerProtocol> recompiler = [self recompilerForUR:openedFileURL];
        [recompiler recompileFileAtURL:openedFileURL completion:^(NSError * error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSAlert * alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"Failed to inject code"];
                    [alert setInformativeText:[error localizedDescription]];
                    [alert setAlertStyle:NSCriticalAlertStyle];
                    [alert runModal];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showResultViewWithSuccess:NO];
                });

            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showResultViewWithSuccess:YES];
                });
            }
        }];
        return;
    }

    NSLog(@"Coudln't find IDEEditorContext... Seems you've pressed somewhere in incorrect place");

}

- (id <SFDYCIRecompilerProtocol>)recompilerForUR:(NSURL *)url {
    for (id<SFDYCIRecompilerProtocol>recompiler in self.recompilers) {
      if ([recompiler canRecompileFileAtURL:url]) {
          return recompiler;
      }
    }
    return nil;
}


- (void)showResultViewWithSuccess:(BOOL)success {
    SFDYCIResultView * resultView = [[SFDYCIResultView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    resultView.success = success;

    // Adding result view on window
    [[[NSApp keyWindow] contentView] addSubview:resultView];


    // Performing animations
    resultView.alphaValue = 0.0;

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * context) {

        context.duration = 1;
        [[resultView animator] setAlphaValue:1.0];

    }                   completionHandler:^{

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * context) {
            context.duration = 1;
            [[resultView animator] setAlphaValue:0.0];
        }                   completionHandler:^{
            [resultView removeFromSuperview];
        }];

    }];

}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
