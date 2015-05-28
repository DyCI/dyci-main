//
//  SFDYCIHelper.m
//  SFDYCIHelper
//
//  Created by Paul Taykalo on 09/07/12.
//
//

#import "SFDYCIHelper.h"
#import "SFDYCIResultView.h"


@implementation SFDYCIHelper

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
   NSMenuItem * runMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
   if (runMenuItem) {
      
      NSMenu * subMenu = [runMenuItem submenu];
      
      // Adding separator
      [subMenu addItem:[NSMenuItem separatorItem]];
      
      // Adding inject item
      NSMenuItem * recompileAndInjectMenuItem =
      [[NSMenuItem alloc] initWithTitle:@"Recompile and inject"
                                  action:@selector(recompileAndInject:)
                           keyEquivalent:@"x"];
      [recompileAndInjectMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
      [recompileAndInjectMenuItem setTarget:self];
      [subMenu addItem:recompileAndInjectMenuItem];
      
   }
   
}

#pragma mark - Preferences

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


- (IDEEditorDocument *)currentDocument  {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        return editorArea.primaryEditorDocument;
    }
    return nil;
}

- (void)recompileAndInject:(id)sender {
    if ([[self currentDocument] isDocumentEdited]) {
        [[self currentDocument] saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:nil];
    } else {
        [self recompileAndInjectAfterSave: nil];
    }
    
}

- (void)document:(NSDocument *)document didSave:(BOOL)didSaveSuccessfully contextInfo:(void *)contextInfo {
    [self recompileAndInjectAfterSave: nil];
}

- (void)recompileAndInjectAfterSave:(id)sender {
   NSLog(@"Yupee :)");
   NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
   NSLog(@"firstResponder = %@", firstResponder);


   // Searching our IDEEditorContext
   // This class has information about URL of file that being edited

   while (firstResponder) {
      firstResponder = [firstResponder nextResponder];

      NSLog(@"Responder is :%@", firstResponder);
      
      if ([firstResponder isKindOfClass:NSClassFromString(@"IDEEditorContext")]) {

         // Resolving currently opened file
         NSURL * openedFileURL = [firstResponder valueForKeyPath:@"editor.document.fileURL"];

         NSLog(@"Opened file url is : %@", openedFileURL);
         // Setting up task, that we are going to call

         NSTask * task = [[NSTask alloc] init];
         [task setLaunchPath:@"/usr/bin/python"];
         NSString * dyciDirectoryPath = [@"~" stringByExpandingTildeInPath];
         dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@".dyci"];
         dyciDirectoryPath = [dyciDirectoryPath stringByAppendingPathComponent:@"scripts"];

         [task setCurrentDirectoryPath:dyciDirectoryPath];

         NSString * dyciRecompile = [dyciDirectoryPath stringByAppendingPathComponent:@"dyci-recompile.py"];

         NSArray * arguments = [NSArray arrayWithObjects:dyciRecompile, [openedFileURL path], nil];
         [task setArguments:arguments];


         // Setting up pipes for standart and error outputs
         NSPipe * outputPipe = [NSPipe pipe];
         NSFileHandle * outputFile = [outputPipe fileHandleForReading];
         [task setStandardOutput:outputPipe];

         NSPipe * errorPipe = [NSPipe pipe];
         NSFileHandle * errorFile = [errorPipe fileHandleForReading];
         [task setStandardError:errorPipe];
         
         // Setting up termination handler
          __weak __typeof(task) weakTask = task;
         [task setTerminationHandler:^(NSTask * tsk) {
            
            NSData * outputData = [outputFile readDataToEndOfFile];
            NSString * outputString = [[NSString alloc] initWithData:outputData
                                                             encoding:NSUTF8StringEncoding];
            if (outputString && [outputString length]) {
              NSLog(@"script returned OK:\n%@", outputString);
            }
            
            NSData * errorData = [errorFile readDataToEndOfFile];
            NSString * errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            if (errorString && [errorString length]) {
               NSLog(@"script returned ERROR:\n%@", errorString);
            }
            // TODO : Need to add correct notification if something went wrong
            if (weakTask.terminationStatus != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{

               NSAlert * alert = [[NSAlert alloc] init];
               [alert addButtonWithTitle:@"OK"];
               [alert setMessageText:@"Failed to inject code"];
               [alert setInformativeText:errorString];
               [alert setAlertStyle:NSCriticalAlertStyle];
               [alert runModal];
               });
               dispatch_async(dispatch_get_main_queue(), ^{
                  [self showResultViewWithSuccess:NO];
               });

            }  else {
               dispatch_async(dispatch_get_main_queue(), ^{
                  [self showResultViewWithSuccess:YES];
               });
            }

            tsk.terminationHandler = nil;

         }];


         // Starting task
         [task launch];

         return;
      }
   }
   
   NSLog(@"Coudln't find IDEEditorContext... Seems you've pressed somewhere in incorrect place");
   
}


- (void)showResultViewWithSuccess:(BOOL)success {
   SFDYCIResultView * resultView = [[SFDYCIResultView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
   resultView.success = success;

   // Adding result view on window
   [[[NSApp keyWindow] contentView] addSubview:resultView];


   // Performing animations
   resultView.alphaValue = 0.0;

   [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {

      context.duration = 1;
      [[resultView animator] setAlphaValue:1.0];

   } completionHandler:^{

      [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
         context.duration = 1;
         [[resultView animator] setAlphaValue:0.0];
      } completionHandler:^{
         [resultView removeFromSuperview];
      }];

   }];

}

#pragma mark - Dealloc

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
