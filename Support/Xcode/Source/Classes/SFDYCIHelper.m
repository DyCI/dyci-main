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
      [[[NSMenuItem alloc] initWithTitle:@"Recompile and inject"
                                  action:@selector(recompileAndInject:)
                           keyEquivalent:@"x"] autorelease];
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


- (void)recompileAndInject:(id)sender {
   NSLog(@"Yupee :)");
   NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
   NSLog(@"firstResponder = %@", firstResponder);


   // Searching our IDEEditorContext
   // This class has information about URL of file that being edited

   while (firstResponder) {
      firstResponder = [firstResponder nextResponder];

      if ([firstResponder isKindOfClass:NSClassFromString(@"IDEEditorContext")]) {

         // Resolving currently opened file
         NSURL * openedFileURL = [firstResponder valueForKeyPath:@"editor.document.fileURL"];


         // Setting up task, that we are going to call


         // TODO : run task in another thread, and check if one is currenlty being running
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

         [task launch];
         
         NSData * outputData = [outputFile readDataToEndOfFile];
         NSString * outputString = [[[NSString alloc] initWithData:outputData
                                                          encoding:NSUTF8StringEncoding] autorelease];
         NSLog(@"script returned OK:\n%@", outputString);
         
         NSData * errorData = [errorFile readDataToEndOfFile];
         NSString * errorString = [[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] autorelease];
         NSLog(@"script returned ERROR:\n%@", errorString);

         SFDYCIResultView * resultView = [[[SFDYCIResultView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)] autorelease];

         // TODO : Need to add correct notifaction if something went wrong
         if (task.terminationStatus != 0) {
            NSAlert * alert = [[[NSAlert alloc] init] autorelease];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Failed to inject code"];
            [alert setInformativeText:errorString];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert runModal];
            [alert release];
            resultView.success = NO;

         }  else {

            resultView.success = YES;

         }

         [[[NSApp keyWindow] contentView] addSubview:resultView];
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

         [task release];
         
      }
   }
   
}


#pragma mark - Dealloc

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}

@end
