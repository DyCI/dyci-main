//
//  SFDCIHelper.m
//  SFDCIHelper
//
//  Created by Paul Taykalo on 09/07/12.
//
//

#import "SFDCIHelper.h"
#import "SFDCIResultView.h"


@implementation SFDCIHelper

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
      [[NSNotificationCenter defaultCenter] addObserver:self
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
      
      NSMenu * submenu = [runMenuItem submenu];
      
      // Adding separator
      [submenu addItem:[NSMenuItem separatorItem]];
      
      // Adding inject item
      NSMenuItem * recompileAndInjectMenuItem =
      [[[NSMenuItem alloc] initWithTitle:@"Recompile and inject"
                                  action:@selector(recompileAndInject:)
                           keyEquivalent:@"x"] autorelease];
      [recompileAndInjectMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
      [recompileAndInjectMenuItem setTarget:self];
      [submenu addItem:recompileAndInjectMenuItem];
      
   }
   
}

#pragma mark - Preferences

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
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
   
   while (firstResponder) {
      firstResponder = [firstResponder nextResponder];
      if ([firstResponder isKindOfClass:NSClassFromString(@"IDEEditorContext")]) {
         
         NSURL * fileUrl = [firstResponder valueForKeyPath:@"editor.document.fileURL"];
         
         
         NSTask * task = [[NSTask alloc] init];
         
         [task setLaunchPath:@"/usr/bin/python"];
         NSString * dciDirectoryPath = [@"~" stringByExpandingTildeInPath];
         dciDirectoryPath = [dciDirectoryPath stringByAppendingPathComponent:@".dci"];
         dciDirectoryPath = [dciDirectoryPath stringByAppendingPathComponent:@"scripts"];
         
         [task setCurrentDirectoryPath:dciDirectoryPath];
         
         NSString * dciRecompile = [dciDirectoryPath stringByAppendingPathComponent:@"dci-recompile.py"];
         
         NSArray * arguments = [NSArray arrayWithObjects:dciRecompile, [fileUrl path], nil];
         [task setArguments:arguments];
         
         NSPipe * outputPipe = [NSPipe pipe];
         [task setStandardOutput:outputPipe];
         NSPipe * errorPipe = [NSPipe pipe];
         [task setStandardError:errorPipe];
         
         NSFileHandle * outputFile = [outputPipe fileHandleForReading];
         NSFileHandle * errorFile = [errorPipe fileHandleForReading];
         
         [task launch];
         
         NSData * outputData = [outputFile readDataToEndOfFile];
         NSString * outputString = [[[NSString alloc] initWithData:outputData
                                                          encoding:NSUTF8StringEncoding] autorelease];
         NSLog(@"script returned OK:\n%@", outputString);
         
         NSData * errorData = [errorFile readDataToEndOfFile];
         NSString * errorString = [[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] autorelease];
         NSLog(@"script returned ERROR:\n%@", errorString);

         SFDCIResultView * resultView = [[[SFDCIResultView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)] autorelease];

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


#pragma mark -

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}

@end
